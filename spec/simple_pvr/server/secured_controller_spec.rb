require 'simple_pvr'
require 'rack/test'

module SimplePvr
  module Server
    class SecuredTestController < SecuredController
      class << self
        attr_accessor :http_username_for_test
        attr_accessor :http_password_for_test
      end
      
      get '/action' do
        'Your response!'
      end
      
      def http_username
        SecuredTestController.http_username_for_test
      end
      
      def http_password
        SecuredTestController.http_password_for_test
      end
    end
  end
end

module RSpecMixin
  include Rack::Test::Methods
  def app
    SimplePvr::Server::SecuredTestController
  end
end

RSpec.configure { |c| c.include RSpecMixin }

module SimplePvr
  module Server
    describe SecuredController do
      context 'when not secured with user name and password' do
        before do
          SecuredTestController.http_username_for_test = nil
          SecuredTestController.http_password_for_test = nil
        end
        
        it 'should allow access without credentials' do
          get '/action'
          last_response.should be_ok
          last_response.body.should == 'Your response!'
          last_response.headers['WWW-Authenticate'].should be_nil
        end
      end
      
      context 'when secured with user name and password' do
        before do
          SecuredTestController.http_username_for_test = 'me'
          SecuredTestController.http_password_for_test = 'pass'
        end

        it 'should not allow access without credentials' do
          get '/action'
          last_response.status.should == 401
          last_response.body.should be_empty
          last_response.headers['WWW-Authenticate'].should == 'Basic realm="SimplePVR"'
        end
        
        it 'should not allow access with bogus authentication string' do
          get '/action', {}, 'HTTP_AUTHORIZATION' => 'Basic bogus'
          last_response.status.should == 401
          last_response.body.should be_empty
          last_response.headers['WWW-Authenticate'].should == 'Basic realm="SimplePVR"'
        end
        
        it 'should not allow access with wrong user name' do
          get '/action', {}, 'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('wronguser:pass')}"
          last_response.status.should == 401
          last_response.body.should be_empty
          last_response.headers['WWW-Authenticate'].should == 'Basic realm="SimplePVR"'
        end
        
        it 'should not allow access with wrong password' do
          get '/action', {}, 'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('me:wrongpass')}"
          last_response.status.should == 401
          last_response.body.should be_empty
          last_response.headers['WWW-Authenticate'].should == 'Basic realm="SimplePVR"'
        end
        
        it 'should allow access with correct credentials' do
          get '/action', {}, 'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('me:pass')}"
          last_response.should be_ok
          last_response.body.should == 'Your response!'
          last_response.headers['WWW-Authenticate'].should be_nil
        end
        
        it 'should also allow access with credentials in cookie' do
          set_cookie "basicCredentials=#{Base64.encode64('me:pass')}"
          get '/action'
          last_response.should be_ok
          last_response.body.should == 'Your response!'
          last_response.headers['WWW-Authenticate'].should be_nil
        end
        
        it 'should give bogus authentication scheme when called from XMLHttpRequest to avoid browser popping up its own log-in dialog' do
          get '/action', {}, 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest'
          last_response.status.should == 401
          last_response.body.should be_empty
          last_response.headers['WWW-Authenticate'].should == 'xBasic realm="SimplePVR"'
        end
        
        it 'should allow access when called from XMLHttpRequest with correct credentials' do
          get '/action', {}, 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest', 'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('me:pass')}"
          last_response.should be_ok
          last_response.body.should == 'Your response!'
          last_response.headers['WWW-Authenticate'].should be_nil
        end
      end
    end
  end
end