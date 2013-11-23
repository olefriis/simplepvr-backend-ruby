require 'fileutils'

module SimplePvr
  class Recorder
    def initialize(tuner, recording)
      @tuner, @recording = tuner, recording
    end
  
    def start!
      @directory = PvrInitializer.recording_manager.create_directory_for_recording(@recording)
      PvrInitializer.hdhomerun.start_recording(@tuner, @recording.channel.frequency, @recording.channel.channel_id, @directory)
      
      icon_url = @recording.programme.icon_url
      ProgrammeIconFetcher.fetch(icon_url, "#{@directory}/icon") if icon_url
      
      PvrLogger.info "Started recording #{@recording.show_name} in #{@directory}"
    end
  
    def stop!
      PvrInitializer.hdhomerun.stop_recording(@tuner)
      Ffmpeg.create_thumbnail_for(@directory)
    
      PvrLogger.info "Stopped recording #{@recording.show_name}"
    end
  end
end