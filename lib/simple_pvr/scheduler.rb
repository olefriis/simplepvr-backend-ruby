module SimplePvr
  class Scheduler
    attr_reader :upcoming_recordings
    
    def initialize
      @number_of_tuners = 2
      @current_recordings = [nil] * @number_of_tuners
      @recorders = {}
      @upcoming_recordings = []
      @mutex = Mutex.new
    end

    def start
      @thread = Thread.new do
        while true
          @mutex.synchronize { process }
          sleep 1
        end
      end
    end

    def recordings=(recordings)
      @mutex.synchronize do
        @upcoming_recordings = recordings.reject {|r| r.expired? }.sort_by {|r| r.start_time }

        @scheduled_programme_ids = programme_ids_from(@upcoming_recordings)
        stop_current_recordings_not_relevant_anymore
        @upcoming_recordings = remove_current_recordings(@upcoming_recordings)
        mark_conflicting_recordings(@upcoming_recordings)
        @conflicting_programme_ids = programme_ids_from(@upcoming_recordings.find_all {|r| r.conflicting? })
      end
    end
    
    def scheduled?(programme)
      @scheduled_programme_ids[programme.id] != nil
    end
    
    def conflicting?(programme)
      @conflicting_programme_ids[programme.id] != nil
    end
    
    def status_text
      @mutex.synchronize do
        return 'Idle' unless is_recording?

        status_texts = active_recordings.map {|recording| "'#{recording.show_name}' on channel '#{recording.channel.name}'"}
        'Recording ' + status_texts.join(', ')
      end
    end

    def process
      stop_expired_recordings
      start_new_recordings
    end
    
    private
    def mark_conflicting_recordings(recordings)
      concurrent_recordings = active_recordings
      recordings.each do |recording|
        concurrent_recordings = concurrent_recordings.reject {|r| r.expired_at(recording.start_time) }
        recording.conflicting = concurrent_recordings.size >= @number_of_tuners
        concurrent_recordings << recording unless recording.conflicting?
      end
    end
    
    def is_recording?
      !active_recordings.empty?
    end
    
    def active_recordings
      @current_recordings.find_all {|recording| recording != nil }
    end
    
    def programme_ids_from(recordings)
      result = {}
      recordings.each do |recording|
        result[recording.programme.id] = true if recording.programme
      end
      result
    end
    
    def remove_current_recordings(recordings)
      recordings.find_all {|recording| !@current_recordings.include?(recording) }
    end
    
    def stop_current_recordings_not_relevant_anymore
      @current_recordings.find_all {|r| r != nil }.each do |recording|
        similar_recording = @upcoming_recordings.find {|r| recording.similar_to(r) }
        if similar_recording
          # It's (probably) the same show, so we continue recording and update with new information
          similar_recording.update_with(recording)
        else
          stop_recording(recording)
        end
      end
    end
    
    def stop_expired_recordings
      @current_recordings.each do |recording|
        stop_recording(recording) if recording && recording.expired?
      end
    end
    
    def start_new_recordings
      while should_start_next_recording
        start_next_recording
      end
    end
    
    def should_start_next_recording
      next_recording = @upcoming_recordings[0]
      next_recording && next_recording.start_time <= Time.now
    end
    
    def stop_recording(recording)
      @recorders[recording].stop!
      @recorders[recording] = nil
      @current_recordings[@current_recordings.find_index(recording)] = nil
    end
    
    def start_next_recording
      next_recording = @upcoming_recordings.delete_at(0)
      available_slot = @current_recordings.find_index(nil)
      if available_slot
        recorder = Recorder.new(available_slot, next_recording)
        @current_recordings[available_slot] = next_recording
        @recorders[next_recording] = recorder
        recorder.start!
      end
    end
  end
end