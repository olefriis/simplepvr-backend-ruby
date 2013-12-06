require 'simple_pvr'

module SimplePvr
  describe ProgrammeIconFetcher do
    before do
      @recording_dir = File.dirname(__FILE__) + '/../resources/recordings'
      FileUtils.rm_rf(@recording_dir) if Dir.exists?(@recording_dir)
      FileUtils.mkdir_p(@recording_dir)
    end
    
    it 'fetches image and stores it in specified location' do
      destination_file = "#{@recording_dir}/dummyImage.png"

      # We're using open-uri, which unfortunately does not understand file://, which would be perfect for
      # this unit test. However, URLs starting with / are apparently interpreted as normal files.
      source_url = "#{File.dirname(__FILE__)}/../resources/dummyImage.png"

      Thread.should_receive(:new).and_yield
      
      ProgrammeIconFetcher.fetch(source_url, destination_file)
      
      File.read(destination_file).should == 'This is not really a PNG file...'
    end
  end
end