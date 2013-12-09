#encoding: UTF-8
require 'simple_pvr'

module SimplePvr
  describe XmltvReader do
    before do
      Model::DatabaseInitializer.prepare_for_test
      Model::DatabaseInitializer.clear
  
      Model::Channel.create(name: 'DR 1')
  
      @xmltv_reader = XmltvReader.new({'www.ontv.dk/tv/1' => 'DR 1'})
    end
    
    it 'populates programme information through the DAO' do
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes.xmltv'))
      
      noddy = Model::Programme.first(title: 'Noddy')
      noddy.channel.name.should == 'DR 1'
      noddy.title.should == 'Noddy'
      noddy.subtitle.should == 'Bare vær dig selv, Noddy.'
      noddy.description.should == "Tegnefilm.\nHer kommer Noddy - så kom ud og leg! Den lille dreng af træ har altid travlt med at køre sine venner rundt i Legebyen - og du kan altid høre, når han er på vej!"
      noddy.start_time.should == Time.new(2012, 7, 17, 6, 0, 0, "+02:00")
      noddy.duration.should == 10.minutes
      noddy.episode_num.should == ' .2/12. '
    end
    
    it 'reads programme icons where available' do
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes-with-icons.xmltv'))
      
      maria_wern = Model::Programme.first(title: 'Maria Wern: Alle de stille døde')
      maria_wern.icon_url.should == 'http://static.timefor.tv/imgs/print_img.php?sti=imgs/epg/channel/2013-11-17/528381020f0c1.jpg&height=300&width=300'
    end
    
    it 'reads programme directors where available' do
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes-with-credits.xmltv'))
      
      maria_wern = Model::Programme.first(title: 'Maria Wern: Alle de stille døde')
      maria_wern.directors.length.should == 1
      maria_wern.directors[0].name.should == 'Erik Leijonborg'
    end
    
    it 'reads programme presenters where available' do
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes-with-presenters.xmltv'))
      
      maria_wern = Model::Programme.first(title: 'Natholdet')
      maria_wern.presenters.length.should == 1
      maria_wern.presenters[0].name.should == 'Anders Breinholt.'
    end
    
    it 'reads programme actors where available' do
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes-with-credits.xmltv'))
      
      maria_wern = Model::Programme.first(title: 'Maria Wern: Alle de stille døde')
      maria_wern.actors.length.should == 3
      maria_wern.actors[0].role_name.should == 'Maria Wern'
      maria_wern.actors[0].actor_name.should == 'Eva Röse'
      maria_wern.actors[1].role_name.should == 'Thomas Hartman'
      maria_wern.actors[1].actor_name.should == 'Allan Svensson'
    end
    
    it 'reads programme categories' do
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes-with-categories.xmltv'))
      
      noddy = Model::Programme.first(title: 'Noddy')
      noddy.categories.length.should == 2
      noddy.categories[0].name.should == 'kids'
      noddy.categories[1].name.should == 'serie'
      
      black_business = Model::Programme.first(title: 'Black Business')
      black_business.categories.length.should == 2
      black_business.categories[0].name.should == 'documentary'
      black_business.categories[1].name.should == 'serie'
    end
    
    it 'ignores programmes for channels with no mapping' do
      # There are two channels in the XMLTV file, but only one with a mapping
      Model::Programme.should_receive(:add).exactly(5).times
  
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes.xmltv'))
    end
  
    it 'adds channel icons to existing channels' do
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes.xmltv'))
      
      dr_1 = Model::Channel.first(name: 'DR 1')
      dr_1.icon_url.should == 'http://ontv.dk/imgs/epg/logos/dr1_big.png'
    end
  
    it 'has no problem with xml with no channel icons' do
      @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programmes-without-icon.xmltv'))
      
      dr_1 = Model::Channel.first(name: 'DR 1')
      dr_1.icon_url.should be_nil
    end
  end
end