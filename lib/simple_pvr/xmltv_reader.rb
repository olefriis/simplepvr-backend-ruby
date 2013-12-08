require 'nokogiri'

module SimplePvr
  class XmltvReader
    include Model
    
    def initialize(mapping_to_channels)
      @channel_name_from_id = mapping_to_channels
      @channel_from_name = {}
      Channel.all.each do |channel|
        @channel_from_name[channel.name] = channel
      end
    end
    
    def read(input)
      doc = Nokogiri::XML.parse(input)

      Programme.transaction do
        Programme.clear

        doc.xpath('/tv/channel').each do |channel|
          process_channel(channel)
        end

        doc.xpath('/tv/programme').each do |programme|
          process_programme(programme)
        end
      end
    end

    def process_channel(channel_xml)
      channel_id = channel_xml[:id]
      channel_name = @channel_name_from_id[channel_id.to_s]
      set_channel_metadata(channel_name, channel_xml) if channel_name
    end

    def set_channel_metadata(channel_name, channel_xml)
      channel = channel_from_name(channel_name)

      icon_xml = channel_xml.xpath("icon").first
      channel.icon_url = icon_xml[:src] if icon_xml
    end

    private
    def process_programme(programme)
      channel_id = programme[:channel]
      channel_name = @channel_name_from_id[channel_id.to_s]

      add_programme(channel_name, programme) if channel_name
    end
    
    def add_programme(channel_name, programme)
      title_node, subtitle_node, description_node, episode_num_node, icon_node, credits_node = nil
      category_nodes = []
      
      programme.children.each do |child|
        case child.name
        when 'title'
          title_node = child
        when 'sub-title'
          subtitle_node = child
        when 'desc'
          description_node = child
        when 'episode-num'
          episode_num_node = child
        when 'icon'
          icon_node = child
        when 'category'
          category_nodes << child
        when 'credits'
          credits_node = child
        end
      end
      
      title = title_node.text
      subtitle = subtitle_node ? subtitle_node.text : ''
      description = description_node ? description_node.text : ''
      episode_num = episode_num_node ? episode_num_node.text : ''
      start_time = Time.parse(programme[:start])
      stop_time = Time.parse(programme[:stop])
      icon_url = icon_node ? icon_node['src'] : nil

      programme = Programme.add(channel_from_name(channel_name), title, subtitle, description, start_time, stop_time - start_time, episode_num, icon_url)
      
      if programme
        add_categories(programme, category_nodes)
        add_credits(programme, credits_node) if credits_node
      end
    end
    
    def add_categories(programme, category_nodes)
      category_nodes.each do |child|
        programme.categories.create(language: child[:language], name: child.text)
      end
    end
    
    def add_credits(programme, credits_node)
      credits_node.children.each do |child|
        case child.name
        when 'director'
          programme.directors.create(name: child.text)
        when 'actor'
          programme.actors.create(role_name: child[:role], actor_name: child.text)
        end
      end
    end
    
    def channel_from_name(channel_name)
      channel = @channel_from_name[channel_name]
      raise Exception, "Unknown channel: #{channel_name}" unless channel
      channel
    end
  end
end