module SimplePvr
  module Server
    class SecuredController < BaseController
      http_username, http_password = ENV['username'], ENV['password']
      security_enabled = http_username && http_password

      if security_enabled
        PvrLogger.info('Securing server with Basic HTTP Authentication')
        use Rack::Auth::Basic, 'Restricted Area' do |username, password|
          [username, password] == [http_username, http_password]
        end
      else
        PvrLogger.info('Beware: Unsecured server. Do not expose to the rest of the world!')
      end
    end
  end
end