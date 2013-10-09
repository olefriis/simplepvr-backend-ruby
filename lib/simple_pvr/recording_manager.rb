module SimplePvr
  RecordingMetadata = Struct.new(:id, :has_thumbnail, :has_webm, :show_name, :channel, :subtitle, :description, :start_time, :duration)
  
  class RecordingManager
    def initialize(recordings_directory=nil)
      @recordings_directory = recordings_directory || Dir.pwd + '/recordings'
    end
    
    def shows
      Dir.new(@recordings_directory).entries - ['.', '..']
    end
    
    def delete_show(show_name)
      FileUtils.rm_rf(directory_for_show(show_name))
    end
    
    def recordings_of(show_name)
      recordings = Dir.new(directory_for_show(show_name)).entries - ['.', '..']
      recordings.sort.map do |recording_id|
        metadata_for(show_name, recording_id)
      end
    end
    
    def metadata_for(show_name, recording_id)
      metadata_file_name = directory_for_show_and_recording(show_name, recording_id) + '/metadata.yml'
      metadata = File.exists?(metadata_file_name) ? YAML.load_file(metadata_file_name) : {}

      thumbnail_file_name = directory_for_show_and_recording(show_name, recording_id) + '/thumbnail.png'
      has_thumbnail = File.exists?(thumbnail_file_name)

      webm_file_name = directory_for_show_and_recording(show_name, recording_id) + '/stream.webm'
      has_webm = File.exists?(webm_file_name)

      RecordingMetadata.new(
        recording_id,
        has_thumbnail,
        has_webm,
        show_name,
        metadata[:channel],
        metadata[:subtitle],
        metadata[:description],
        metadata[:start_time],
        metadata[:duration])
    end

    def delete_show_recording(show_name, recording_id)
      FileUtils.rm_rf(@recordings_directory + '/' + show_name + '/' + recording_id)
    end

    def create_directory_for_recording(recording)
      show_directory = directory_for_show(recording.show_name)
      ensure_directory_exists(show_directory)

      recording_subdirectory = subdirectory_for_recording(recording, show_directory)
      recording_directory = "#{show_directory}/#{recording_subdirectory}"
      ensure_directory_exists(recording_directory)

      create_metadata(recording_directory, recording)

      recording_directory
    end
    
    def directory_for_show_and_recording(show_name, recording_id)
      directory_for_show(show_name) + '/' + recording_id
    end

    private
    def directory_for_show(show_name)
      sanitized_directory_name = show_name.gsub(/\"|\'|\*|\.|\/|\\|:/, '')
      directory_name = sanitized_directory_name.present? ? sanitized_directory_name : 'Unnamed'
      @recordings_directory + '/' + directory_name
    end
    
    def ensure_directory_exists(directory)
      FileUtils.makedirs(directory) unless File.exists?(directory)
    end
    
    def subdirectory_for_recording(recording, base_directory)
      start_time_millis = recording.start_time.to_i
      path = "#{base_directory}/#{start_time_millis}"
      return "#{start_time_millis}" unless File.exists?(path)

      sequence_number = 1
      while File.exists?("#{path}-#{sequence_number}")
        sequence_number += 1
      end
      "#{start_time_millis}-#{sequence_number}"
    end
    
    def create_metadata(directory, recording)
      metadata = {
        title: recording.show_name,
        channel: recording.channel.name,
        start_time: recording.start_time,
        duration: recording.duration
      }
      
      if recording.programme
        metadata.merge!({
          subtitle: recording.programme.subtitle,
          description: recording.programme.description
        })
      end
            
      File.open(directory + '/metadata.yml', 'w') {|f| f.write(metadata.to_yaml) }
    end
  end
end