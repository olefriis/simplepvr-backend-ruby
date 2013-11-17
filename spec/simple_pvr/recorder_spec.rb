require 'simple_pvr'

module SimplePvr
  describe Recorder do
    before do
      @channel = Model::Channel.new(frequency: 282000000, channel_id: 1098)
      @recording = Model::Recording.new(@channel, 'Star Trek', 'start time', 'duration')
  
      @hdhomerun = double('HDHomeRun')
      PvrInitializer.stub(hdhomerun: @hdhomerun)
  
      @recording_manager = double('RecordingManager')
      @recording_manager.stub(:create_directory_for_recording).with(@recording).and_return('recording directory')  
      PvrInitializer.stub(recording_manager: @recording_manager)
      
      @recorder = Recorder.new(1, @recording)
    end
    
    it 'can start recording' do
      @hdhomerun.should_receive(:start_recording).with(1, 282000000, 1098, 'recording directory')
    
      @recorder.start!
    end
    
    it 'can stop recording as well, and creates a thumbnail' do
      @hdhomerun.stub(:start_recording)
      @hdhomerun.should_receive(:stop_recording).with(1)
      Ffmpeg.should_receive(:create_thumbnail_for).with('recording directory')
    
      @recorder.start!
      @recorder.stop!
    end
  end
end
