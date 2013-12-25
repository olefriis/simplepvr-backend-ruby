module SimplePvr
  module Server
    class StatusController < SecuredController
      get '/' do
        {
          status_text: PvrInitializer.scheduler.status_text
        }.to_json
      end
    end
  end
end
