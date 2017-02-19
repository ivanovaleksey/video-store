module Services
  class Video
    attr_reader :video

    def initialize(params)
      @video = ::Video.new(params)
      @video.assign_attributes(movie_attributes)
    end

    def create
      if @video.save
        start_processing
        spawn_thumbnail_worker
        spawn_watermark_worker
        true
      else
        # TODO: put some logic here
        false
      end
    end

    private

    def movie_attributes
      movie = @video.movie
      return {} unless movie
      {
        duration: movie.duration,
        size:     movie.size
      }
    end

    def start_processing
      @video.process
    end

    def spawn_thumbnail_worker
      ThumbnailWorker.perform_async(@video.id)
    end

    def spawn_watermark_worker
      WatermarkWorker.perform_async(@video.id)
    end
  end
end
