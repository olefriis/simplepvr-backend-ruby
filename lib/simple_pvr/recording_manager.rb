module SimplePvr
  RecordingMetadata = Struct.new(:id, :status, :status_text, :has_icon, :has_thumbnail, :has_webm, :show_name, :channel, :subtitle, :description, :categories, :directors, :presenters, :actors, :start_time, :duration)
  
  class RecordingManager
    def initialize(recordings_directory)
      @recordings_directory = recordings_directory
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
      recording_directory = directory_for_show_and_recording(show_name, recording_id)
      
      metadata_file_name = recording_directory + '/metadata.yml'
      metadata = File.exists?(metadata_file_name) ? YAML.load_file(metadata_file_name) : {}

      icon_file_name = recording_directory + '/icon'
      has_icon = File.exists?(icon_file_name)

      thumbnail_file_name = recording_directory + '/thumbnail.png'
      has_thumbnail = File.exists?(thumbnail_file_name)

      webm_file_name = recording_directory + '/stream.webm'
      has_webm = File.exists?(webm_file_name)

      status, status_text = status_and_status_text_for_hdhomerun_save_log(recording_directory)

      RecordingMetadata.new(
        recording_id,
        status,
        status_text,
        has_icon,
        has_thumbnail,
        has_webm,
        show_name,
        metadata[:channel],
        metadata[:subtitle],
        metadata[:description],
        metadata[:categories] || [],
        metadata[:directors] || [],
        metadata[:presenters] || [],
        metadata[:actors] || [],
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
    
    def status_and_status_text_for_hdhomerun_save_log(directory)
      log_file_name = directory + '/hdhomerun_save.log'
      if !File.exists?(log_file_name)
        return ['error', 'No log file exists - maybe this is not a SimplePVR recording?']
      end
      
      log_file = IO.readlines(log_file_name)
      if log_file.length != 3 || !(log_file[2] =~ /^(\d+) packets received, (\d+) overflow errors, (\d+) network errors, (\d+) transport errors, (\d+) sequence errors$/)
        return ['error', 'Invalid log file format']
      end
      
      packets_received, overflow_errors, network_errors, transport_errors, sequence_errors = $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i

      errors = []
      errors << "#{overflow_errors} overflow errors" if overflow_errors > 0
      errors << "#{network_errors} network errors" if network_errors > 0
      errors << "#{transport_errors} transport errors" if transport_errors > 0
      errors << "#{sequence_errors} sequence errors" if sequence_errors > 0
      error_text = errors.join("\n")

      if packets_received == 0
        return ['error', 'Empty recording']
      elsif !log_file[0].include?('.')
        ['error', "Failed recording.\n#{error_text}"]
      elsif !errors.empty?
        ['warning', "Some errors during recording.\n#{error_text}"]
      else
        ['success', '']
      end
    end
    
    def create_metadata(directory, recording)
      metadata = {
        title: recording.show_name,
        channel: recording.channel.name,
        start_time: recording.start_time,
        duration: recording.duration
      }
      
      programme = recording.programme
      if programme
        metadata.merge!({
          subtitle: programme.subtitle,
          description: programme.description,
          categories: programme.categories.map { |category| category.name },
          directors: programme.directors.map { |director| director.name },
          presenters: programme.presenters.map { |presenter| presenter.name },
          actors: programme.actors.map { |actor| { role_name: actor.role_name, actor_name: actor.actor_name } }
        })
      end
            
      File.open(directory + '/metadata.yml', 'w') {|f| f.write(metadata.to_yaml) }
    end
  end
end