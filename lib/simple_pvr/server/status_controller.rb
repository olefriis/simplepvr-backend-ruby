module SimplePvr
  module Server
    class StatusController < SecuredController
      get '/' do
        status = StatusReporter.report
        
        {
          status_text: status.status_text,
          total_disk_space: status.total_disk_space,
          free_disk_space: status.free_disk_space
        }.to_json
      end
    end
  end
end
