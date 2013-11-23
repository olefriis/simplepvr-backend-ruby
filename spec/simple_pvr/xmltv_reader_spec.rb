#encoding: UTF-8
require 'simple_pvr'

module SimplePvr
  describe XmltvReader do
    before do
      @dr_1 = double(name: 'DR 1')
      @dr_1.stub(:icon_url=)
  
      Model::Channel.stub(all: [@dr_1])
      Model::Programme.stub(:transaction).and_yield
      Model::Programme.stub(:destroy)
      @xmltv_reader = XmltvReader.new({'www.ontv.dk/tv/1' => 'DR 1'})
    end
    
    it 'populates programme information through the DAO' do
      Model::Programme.stub(:add)
      Model::Programme.should_receive(:add).with(
        @dr_1,
        'Noddy',
        'Bare vær dig selv, Noddy.',
        "Tegnefilm.\nHer kommer Noddy - så kom ud og leg! Den lille dreng af træ har altid travlt med at køre sine venner rundt i Legebyen - og du kan altid høre, når han er på vej!",
        Time.new(2012, 7, 17, 6, 0, 0, "+02:00"),
        10.minutes,
        ' .2/12. ',
        nil)
      
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes.xmltv'))
    end
    
    it 'reads programme icons where available' do
      Model::Programme.should_receive(:add).with(
        @dr_1,
        'Maria Wern: Alle de stille døde',
        'Svensk krimi-miniserie fra 2010.',
        anything(),
        anything(),
        anything(),
        anything(),
        'http://static.timefor.tv/imgs/print_img.php?sti=imgs/epg/channel/2013-11-17/528381020f0c1.jpg&height=300&width=300')
      
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes-with-icons.xmltv'))
    end
    
    it 'ignores programmes for channels with no mapping' do
      # There are two channels in the XMLTV file, but only one with a mapping
      Model::Programme.should_receive(:add).exactly(5).times
  
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes.xmltv'))
    end
  
    it 'adds channel icons to existing channels' do
      Model::Programme.stub(:add) # necessary to deal with the way Programme setup its relation to Channel
      @dr_1.should_receive(:icon_url=).with("http://ontv.dk/imgs/epg/logos/dr1_big.png")
  
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes.xmltv'))
    end
  
    it 'has no problem with xml with no channel icons' do
      Model::Programme.stub(:add) # necessary to deal with the way Programme setup its relation to Channel
      @dr_1.should_not_receive(:icon_url=)
  
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes-without-icon.xmltv'))
    end
  end
end