require 'simple_pvr'

module SimplePvr
  describe StatusReporter do
    MockStat = Struct.new(:blocks, :block_size, :blocks_available)
    
    before do
      scheduler = double('Scheduler')
      scheduler.stub(:status_text).and_return('scheduler status')
      PvrInitializer.should_receive(:scheduler).and_return(scheduler)

      Sys::Filesystem.should_receive(:stat).with('./recordings').and_return(MockStat.new(1000, 8192, 500))

      @status = StatusReporter.report
    end
    
    it 'gets status from scheduler' do
      @status.status_text.should == 'scheduler status'
    end
    
    it 'knows total disk space' do
      kilobyte = 1024
      @status.total_disk_space.should == 8000*kilobyte
    end
    
    it 'knows free disk space' do
      kilobyte = 1024
      @status.free_disk_space.should == 4000*kilobyte
    end
  end
end