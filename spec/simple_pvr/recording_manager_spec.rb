require 'simple_pvr'
require 'yaml'

module SimplePvr
  describe RecordingManager do
    before do
      @resources_dir = File.dirname(__FILE__) + '/../resources'
      @recording_dir = @resources_dir + '/recordings'
      FileUtils.rm_rf(@recording_dir) if Dir.exists?(@recording_dir)
      FileUtils.mkdir_p(@recording_dir + "/series 1/1")
      FileUtils.mkdir_p(@recording_dir + "/series 1/3")
      FileUtils.mkdir_p(@recording_dir + "/Another series/10")
      
      @manager = RecordingManager.new(@recording_dir)
    end
    
    it 'knows which shows are recorded' do
      @manager.shows.size.should == 2
      @manager.shows.should include('Another series', 'series 1')
    end
    
    it 'can delete all recordings of a given show' do
      @manager.delete_show('series 1')
      File.exists?(@recording_dir + '/series 1').should be_false
    end
    
    it 'knows which recordings of a given show exists' do
      recordings = @manager.recordings_of('series 1')
      
      recordings.length.should == 2
      recordings[0].id.should == '1'
      recordings[1].id.should == '3'
    end
  
    it 'can delete a recording of a given show' do
      @manager.delete_show_recording('series 1', '3')
      File.exists?(@recording_dir + '/series 1/3').should be_false
    end
    
    context 'when listing recordings' do
      it 'reads metadata for recordings if present' do
        start_time = Time.now
        metadata = {
          channel: 'Channel 4',
          subtitle: 'A subtitle',
          description: 'A description',
          start_time: start_time,
          duration: 10.minutes
        }
        File.open(@recording_dir + '/series 1/3/metadata.yml', 'w') {|f| f.write(metadata.to_yaml) }
        
        recordings = @manager.recordings_of('series 1')
        
        recordings.length.should == 2
    
        recordings[0].id.should == '1'
        recordings[0].show_name.should == 'series 1'
        
        recordings[1].id.should == '3'
        recordings[1].show_name.should == 'series 1'
        recordings[1].channel.should == 'Channel 4'
        recordings[1].subtitle.should == 'A subtitle'
        recordings[1].description.should == 'A description'
        recordings[1].start_time.to_i.should == start_time.to_i
        recordings[1].duration == 10.minutes
      end
      
      it 'knows when no icon exists' do
        recordings = @manager.recordings_of('series 1')
    
        recordings[0].has_icon.should be_false
      end
      
      it 'knows when icon exists' do
        FileUtils.touch(@recording_dir + "/series 1/1/icon")
        recordings = @manager.recordings_of('series 1')
    
        recordings[0].has_icon.should be_true
      end
      
      it 'knows when no thumbnail exists' do
        recordings = @manager.recordings_of('series 1')
    
        recordings[0].has_thumbnail.should be_false
      end
    
      it 'knows when thumbnail exists' do
        FileUtils.touch(@recording_dir + "/series 1/1/thumbnail.png")
        recordings = @manager.recordings_of('series 1')
    
        recordings[0].has_thumbnail.should be_true
      end
    
      it 'knows when no webm file exists' do
        recordings = @manager.recordings_of('series 1')
    
        recordings[0].has_webm.should be_false
      end
    
      it 'knows when a webm file exists' do
        FileUtils.touch(@recording_dir + "/series 1/1/stream.webm")
        recordings = @manager.recordings_of('series 1')
    
        recordings[0].has_webm.should be_true
      end
      
      it 'flags error when no hdhomerun_save.log exists' do
        recordings = @manager.recordings_of('series 1')

        recordings[0].status.should == 'error'
        recordings[0].status_text.should == 'No log file exists - maybe this is not a SimplePVR recording?'
      end
      
      it 'does not flag error when correct hdhomerun_save.log exists' do
        FileUtils.copy(@resources_dir + '/hdhomerun_save.log', @recording_dir + '/series 1/1/hdhomerun_save.log')
        recordings = @manager.recordings_of('series 1')

        recordings[0].status.should == 'success'
        recordings[0].status_text.should be_empty
      end
      
      it 'flags error when hdhomerun_save.log indicates empty recording' do
        FileUtils.copy(@resources_dir + '/hdhomerun_save-empty.log', @recording_dir + '/series 1/1/hdhomerun_save.log')
        recordings = @manager.recordings_of('series 1')

        recordings[0].status.should == 'error'
        recordings[0].status_text.should == 'Empty recording'
      end
      
      it 'flags error when all packets received contain errors' do
        FileUtils.copy(@resources_dir + '/hdhomerun_save-transporterrors.log', @recording_dir + '/series 1/1/hdhomerun_save.log')
        recordings = @manager.recordings_of('series 1')

        recordings[0].status.should == 'error'
        recordings[0].status_text.should == "Failed recording.\n2697689 transport errors\n34991 sequence errors"
      end
      
      it 'flags warning when some packets received contain errors' do
        FileUtils.copy(@resources_dir + '/hdhomerun_save-variouserrors.log', @recording_dir + '/series 1/1/hdhomerun_save.log')
        recordings = @manager.recordings_of('series 1')

        recordings[0].status.should == 'warning'
        recordings[0].status_text.should == "Some errors during recording.\n1464 transport errors\n162 sequence errors"
      end
    end
    
    context 'when creating recording directories' do
      before do
        @start_time = Time.local(2012, 7, 23, 15, 30, 15)
        @start_time_millis = @start_time.to_i
        @recording = Model::Recording.new(double(name: 'Channel 4'), 'Star Trek', @start_time, 50.minutes)
      end
      
      it 'records to directory with record start time if it does not already exist' do
        @manager.create_directory_for_recording(@recording)
      
        File.exists?("#{@recording_dir}/Star Trek/#{@start_time_millis}").should be_true
      end
  
      it 'appends sequence number to start time if time stamp is already used' do
        FileUtils.mkdir_p("#{@recording_dir}/Star Trek/#{@start_time_millis}")
        @manager.create_directory_for_recording(@recording)
      
        File.exists?("#{@recording_dir}/Star Trek/#{@start_time_millis}-1").should be_true
      end
    
      it 'finds next number in sequence for new directory if time stamp is already used' do
        FileUtils.mkdir_p("#{@recording_dir}/Star Trek/#{@start_time_millis}")
        FileUtils.mkdir_p("#{@recording_dir}/Star Trek/#{@start_time_millis}-1")
        FileUtils.mkdir_p("#{@recording_dir}/Star Trek/#{@start_time_millis}-2")
        @manager.create_directory_for_recording(@recording)
      
        File.exists?("#{@recording_dir}/Star Trek/#{@start_time_millis}-3").should be_true
      end
  
      it 'removes some potentially harmful characters from directory name' do
        @recording.show_name = "Some... harmful/irritating\\ characters in: '*title\""
        @manager.create_directory_for_recording(@recording)
      
        File.exists?("#{@recording_dir}/Some harmfulirritating characters in title/#{@start_time_millis}").should be_true
      end
    
      it 'finds a directory name for titles which would otherwise get an empty directory name' do
        @recording.show_name = '/.'
        @manager.create_directory_for_recording(@recording)
      
        File.exists?("#{@recording_dir}/Unnamed/#{@start_time_millis}").should be_true
      end
    
      it 'stores simple metadata if no programme information exists' do
        @manager.create_directory_for_recording(@recording)
      
        metadata = YAML.load_file("#{@recording_dir}/Star Trek/#{@start_time_millis}/metadata.yml")
        metadata[:title].should == 'Star Trek'
        metadata[:channel].should == 'Channel 4'
        metadata[:start_time].should == @start_time
        metadata[:duration].should == 50.minutes
      end
      
      it 'stores extensive metadata if programme information exists' do
        start_time = Time.local(2012, 7, 23, 15, 30, 15)
        start_time_millis = start_time.to_i
        recording = Model::Recording.new(double(name: 'Channel 4'), 'Extensive Metadata', start_time, 50.minutes)
        recording.programme = Model::Programme.new(subtitle: 'A subtitle', description: "A description,\nspanning several lines")
        recording.programme.categories.new(name: 'series')
        recording.programme.categories.new(name: 'children')
        recording.programme.directors.new(name: 'The director')
        recording.programme.presenters.new(name: 'The presenter')
        recording.programme.actors.new(role_name: 'First role', actor_name: 'First actor')
        recording.programme.actors.new(role_name: 'Second role', actor_name: 'Second actor')
        @manager.create_directory_for_recording(recording)
      
        metadata = YAML.load_file("#{@recording_dir}/Extensive Metadata/#{start_time_millis}/metadata.yml")
        metadata[:title].should == 'Extensive Metadata'
        metadata[:channel].should == 'Channel 4'
        metadata[:start_time].should == start_time
        metadata[:duration].should == 50.minutes
        metadata[:subtitle].should == 'A subtitle'
        metadata[:description].should == "A description,\nspanning several lines"
        metadata[:categories].should == ['series', 'children']
        metadata[:directors].should == ['The director']
        metadata[:presenters].should == ['The presenter']
        metadata[:actors].should == [{role_name: 'First role', actor_name: 'First actor'}, {role_name: 'Second role', actor_name: 'Second actor'}]
      end
    end
  end
end