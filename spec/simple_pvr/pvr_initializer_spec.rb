require 'simple_pvr'

module SimplePvr
  describe PvrInitializer do
    before do
      Model::DatabaseInitializer.stub(:setup)
      
      @scheduler = double('Scheduler')
      Scheduler.stub(new: @scheduler)
      
      @hdhomerun = double('HDHomeRun')
      HDHomeRun.stub(new: @hdhomerun)
      
      @recording_manager = double('RecordingManager')
      RecordingManager.stub(new: @recording_manager)
    end
    
    it 'starts the scheduler' do
      Model::Channel.stub(all: [1, 2, 3, 4, 5])
      @scheduler.should_receive(:start)
  
      PvrInitializer.setup
    end
    
    context 'when scheduler is started' do
      before do
        @scheduler.stub(:start)
      end
    
      it 'runs a channel scan if channels are missing' do
        Model::Channel.stub(all: [])
        @hdhomerun.should_receive(:scan_for_channels)
      
        PvrInitializer.setup
      end
    
      it 'does nothing if channels.txt is present' do
        Model::Channel.stub(all: [1])
  
        PvrInitializer.setup
      end
    
      it 'initializes a HDHomeRun and RecordingManager instance' do
        Model::Channel.stub(all: [1])
      
        PvrInitializer.setup
        PvrInitializer.hdhomerun.should == @hdhomerun
        PvrInitializer.recording_manager.should == @recording_manager
      end
    end
  end
end