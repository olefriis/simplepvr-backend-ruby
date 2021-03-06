require 'sinatra/base'

Time::DATE_FORMATS[:programme_date] = '%F'
Time::DATE_FORMATS[:day] = '%a, %d %b'

module SimplePvr
  module Server
    class BaseController < Sinatra::Base
      include ERB::Util

      configure do
        set :public_folder, File.dirname(__FILE__) + '/../../../public/'
        mime_type :webm, 'video/webm'
      end

      def reload_schedules
        RecordingPlanner.reload
      end

      def programme_hash(programme)
        {
          id: programme.id,
          channel: { id: programme.channel.id, name: programme.channel.name },
          title: programme.title,
          subtitle: programme.subtitle,
          description: programme.description,
          directors: programme.directors.map { |director| director.name },
          presenters: programme.presenters.map { |presenter| presenter.name },
          actors: programme.actors.map { |actor| { role_name: actor.role_name, actor_name: actor.actor_name } },
          categories: programme.categories.map { |category| category.name },
          start_time: programme.start_time,
          is_scheduled: PvrInitializer.scheduler.scheduled?(programme),
          episode_num: programme.episode_num,
          icon_url: programme.icon_url,
          is_outdated: programme.outdated?
        }
      end

      def recording_hash(show_id, recording)
        path = PvrInitializer.recording_manager.directory_for_show_and_recording(show_id, recording.id)
        {
          id: recording.id,
          show_id: show_id,
          subtitle: recording.subtitle,
          description: recording.description,
          directors: recording.directors,
          presenters: recording.presenters,
          actors: recording.actors,
          categories: recording.categories,
          start_time: recording.start_time,
          channel_name: recording.channel,
          status: recording.status,
          status_text: recording.status_text,
          has_icon: recording.has_icon,
          has_thumbnail: recording.has_thumbnail,
          has_webm: recording.has_webm,
          local_file_url: 'file://' + File.join(path, 'stream.ts')
        }
      end

      def channel_with_current_programmes_hash(channel_with_current_programmes)
        channel = channel_with_current_programmes[:channel]
        current_programme = channel_with_current_programmes[:current_programme]
        upcoming_programmes = channel_with_current_programmes[:upcoming_programmes]

        current_programme_map = current_programme ? programme_summary_hash(current_programme) : nil
        upcoming_programmes_map = programme_summaries_hash(upcoming_programmes)

        {
          id: channel.id,
          name: channel.name,
          hidden: channel.hidden,
          icon_url: channel.icon_url,
          current_programme: channel,
          current_programme: current_programme_map,
          upcoming_programmes: upcoming_programmes_map
        }
      end
    
      def programme_summaries_hash(programmes)
        programmes.map {|programme| programme_summary_hash(programme) }
      end
    
      def programme_summary_hash(programme)
        {
          id: programme.id,
          title: programme.title,
          start_time: programme.start_time,
          is_scheduled: PvrInitializer.scheduler.scheduled?(programme),
          is_conflicting: PvrInitializer.scheduler.conflicting?(programme)
        }
      end
    end
  end
end