require 'sys/filesystem'

module SimplePvr
  SimplePvr::Status = Struct.new(:status_text, :total_disk_space, :free_disk_space)
  
  class StatusReporter
    def self.report
      stat = Sys::Filesystem.stat('./recordings')

      status_text = PvrInitializer.scheduler.status_text
      total_disk_space = stat.blocks * stat.block_size
      free_disk_space = stat.blocks_available * stat.block_size
      
      Status.new(status_text, total_disk_space, free_disk_space)
    end
  end
end