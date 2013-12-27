require 'base64'

module SimplePvr
  module Server
    class SecuredController < BaseController
      def username_and_password_from_request
        authorization = env['HTTP_AUTHORIZATION']
        if authorization =~ /Basic ([a-zA-Z0-9\+\/]*[=]{0,2})/
          username_and_password = Base64.decode64($1)
          if username_and_password =~ /(.*):(.*)/
            username, password = $1, $2
            return [username, password]
          end
        end
        [nil, nil]
      end
      
      def is_ajax_call
        env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      end

      http_username, http_password = ENV['username'], ENV['password']
      security_enabled = http_username && http_password

      if security_enabled
        PvrLogger.info('Securing server with Basic HTTP Authentication')
        before do
          return if username_and_password_from_request == [http_username, http_password]
          
          # We don't want AJAX calls to pop up the browser's own log-in dialog, so we
          # give AJAX calls a special scheme. See
          # http://stackoverflow.com/questions/86105/how-can-i-supress-the-browsers-authentication-dialog
          # and
          # http://loudvchar.blogspot.ca/2010/11/avoiding-browser-popup-for-401.html
          scheme = is_ajax_call ? 'xBasic' : 'Basic'

          halt 401, {
            'Content-Type' => 'text/plain',
            'Content-Length' => '0',
            'WWW-Authenticate' => "#{scheme} realm=\"SimplePVR\""
            }, []
        end
      else
        PvrLogger.info('Beware: Unsecured server. Do not expose to the rest of the world!')
      end
    end
  end
end