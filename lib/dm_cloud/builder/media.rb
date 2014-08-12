module DmCloud
  module Builder
    module Media
      # This method can either create an empty media object
      # or also download a media with the url paramater
      # and use it as the source to encode the ASSET_NAME listed in assets_names
      # Params :
      #   args:
      #     url: SCHEME://USER:PASSWORD@HOSTNAME/MY/PATH/FILENAME.EXTENSION (could be ftp or http)
      #     author: an author name
      #     title: a title for the film
      #     assets_names: (Array) – (optional) the list of ASSET_NAME you want to transcode,
      #       when you set this parameter you must also set the url parameter
      # Return :
      #   media_id: return the media id of the object
      def self.create(options = {})
        request = Hash.new
        url = options['url']
        assets_names = options['assets_names']
        assets_parameters = options['assets_parameters']
        meta = options['meta'] || {}

        request['url'] = url

        if !meta.empty?
          request['meta'] = {}
          request['meta']['author'] = meta['author'] if meta['author']
          request['meta']['author'] = meta['title'] if meta['title']
        end

        request['assets_names'] = assets_names unless assets_names.empty?
        request['assets_parameters'] = assets_parameters unless assets_parameters.empty?
        request.rehash
      end

      def self.info(media_id, assets_names = ['source'], fields = {})
        raise StandardError, "missing :media_id in params" unless media_id
        request = Hash.new

        # the media id
        request[:fields] = []

        # requested media meta datas
        fields[:meta] = ['title'] unless fields[:meta]
        fields[:meta].each { |value| request[:fields] << "meta.#{value.to_s}" }
        request[:fields] += ['id', 'created', 'embed_url', 'frame_ratio']

        # the worldwide statistics on the number of views
        # request['fields'] << 'stats.global.last_week' if fields[:stats][:global]

        # TODO: handle statistics request per country
        # fields[:stats].each { |key| request << "meta.#{key.to_s}" } if fields[:meta].present?
        # request['stats'][COUNTRY_CODE][TIME_INTERVAL] : the statistics on the number of views in a specific country (eg: stats.fr.total, stats.us.last_week, etc...)
        # request['extended_stats'][COUNTRY_CODE][TIME_INTERVAL]

        assets_names = ['source'] if assets_names.nil?
        if not fields[:assets]
          request = all_assets_fields(request, assets_names)
        else
          assets_names.each do |name|
            fields[:assets].each { |value| request << "assets.#{name}.#{value.to_s}" }
          end
        end
        request
      end

      def self.list(page = 1, per_page = 10, fields = {})
        # raise StandardError, "missing :media_id in params" unless media_id
        request = Hash.new

        request[:page] = page
        request[:per_page] = per_page
        request[:fields] = []
        # requested media meta datas
        fields[:meta] = ['title'] unless fields[:meta]
        fields[:meta].each { |value| request[:fields] << "meta.#{value.to_s}" }
        request[:fields] += ['id', 'created', 'embed_url', 'frame_ratio']

        # TODO: handle global statistics request in another module
        # the worldwide statistics on the number of views
        # request << 'stats.global.last_week' if fields[:stats][:global]

        # TODO: handle statistics request per country
        # fields[:stats].each { |key| request << "meta.#{key.to_s}" } if fields[:meta].present?
        # request['stats'][COUNTRY_CODE][TIME_INTERVAL] : the statistics on the number of views in a specific country (eg: stats.fr.total, stats.us.last_week, etc...)
        # request['extended_stats'][COUNTRY_CODE][TIME_INTERVAL]

        assets_names = ['source'] if assets_names.nil?
        if not fields[:assets]
          request = all_assets_fields(request, assets_names)
        else
          assets_names.each do |name|
            fields[:assets].each { |value| request[:fields] << "assets.#{name}.#{value.to_s}" }
          end
        end

        request
      end


      protected
        # This method exclude stats, but return all information for a media (video or images)
        # NOTE: This is outside the methods because : too long and recurent.
        #   It's also used as default if no fields params is submitted.
        def self.all_assets_fields(request, assets_names)
          assets_names.each do |name|
            request[:fields] << "assets.#{name}.download_url"
            request[:fields] << "assets.#{name}.status"
            request[:fields] << "assets.#{name}.container"
            request[:fields] << "assets.#{name}.duration"
            request[:fields] << "assets.#{name}.global_bitrate"
            request[:fields] << "assets.#{name}.video_codec"
            request[:fields] << "assets.#{name}.video_width"
            request[:fields] << "assets.#{name}.video_height"
            request[:fields] << "assets.#{name}.video_bitrate"
            request[:fields] << "assets.#{name}.video_rotation"
            request[:fields] << "assets.#{name}.video_fps"
            request[:fields] << "assets.#{name}.video_fps_mode"
            request[:fields] << "assets.#{name}.video_aspect"
            request[:fields] << "assets.#{name}.video_interlaced"
            request[:fields] << "assets.#{name}.audio_codec"
            request[:fields] << "assets.#{name}.audio_bitrate"
            request[:fields] << "assets.#{name}.audio_nbr_channel"
            request[:fields] << "assets.#{name}.audio_samplerate"
            request[:fields] << "assets.#{name}.created"
            request[:fields] << "assets.#{name}.file_extension"
            request[:fields] << "assets.#{name}.file_size"
          end
          request
        end
    end
  end
end