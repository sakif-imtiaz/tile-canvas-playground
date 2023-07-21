module AssetWorkspace
  module SpriteSize
    class Calculator
      ZOOM_MODE = [:zoom_in, :default, :zoom_out]
      attr_reader :asset, :frame_rect

      def initialize(asset, frame_rect)
        @asset, @frame_rect = asset, frame_rect
      end

      def size(zoom = default_zoom)
        send(ZOOM_MODE[(default_zoom.to_f.to_i <=> zoom.to_f.to_i) + 1], zoom)
      end

      def default_zoom
        @_default_zoom ||= calculate_default_zoom
      end

      def calculate_default_zoom
        w_ratio = frame_rect.w.to_f/asset.dimensions.w.to_f
        h_ratio = frame_rect.h.to_f/asset.dimensions.h.to_f

        unrounded_ratio = [
          [(w_ratio - 1).abs, w_ratio],
          [(h_ratio - 1).abs, h_ratio]
        ].min_by(&:first).last

        if unrounded_ratio > 1
          Fraction.new(unrounded_ratio.floor, 1)
        else
          Fraction.new(1, (1.0/unrounded_ratio).ceil)
        end
      end

      def default(_zoom, _input_offset)
        Result.new(
          dimensions: vec2(
            (default_zoom*asset.dimensions.w).to_f.round,
            (default_zoom*asset.dimensions.h).to_f.round
          ),
          source: VP::Rect.new(position: default_offset, dimensions: asset.dimensions),
          frame_rect: frame_rect
        )
      end

      def default_offset(*_args)
        vec2(0, 0)
      end

      def zoom_in(zoom, input_offset)
        r_dims = vec2(
          (zoom*asset.dimensions.w).to_f.round.clamp(0, frame_rect.w),
          (zoom*asset.dimensions.h).to_f.round.clamp(0, frame_rect.h),
        )
        source_dims = vec2(
          (zoom.inverse*r_dims.w).to_f.round,
          (zoom.inverse*r_dims.h).to_f.round,
        )
        r_source = VP::Rect.new(
          position: zoom_in_offset(input_offset, source_dims),
          dimensions: source_dims
        )

        Result.new(dimensions: r_dims, source: r_source, frame_rect: frame_rect)
      end

      def zoom_in_offset(old_offset, source_dims)
        invalid_offsets = quick_rect(
          0, 0,
          asset.dimensions.w - source_dims.w,
          asset.dimensions.h - source_dims.h,
        )
        old_offset.clamp(invalid_offsets)
      end

      def zoom_out(zoom, _input_offset)
        r_dims = vec2(
          (zoom*asset.dimensions.w).to_f.round,
          (zoom*asset.dimensions.h).to_f.round,
        )
        r_source = VP::Rect.new(position: zoom_out_offset, dimensions: asset.dimensions)

        Result.new(dimensions: r_dims, source: r_source, frame_rect: frame_rect)
      end

      def zoom_out_offset(*_args)
        vec2(0, 0)
      end

      def result(zoom:, input_offset: vec2(0,0))
        zoom_mode = ZOOM_MODE[(default_zoom.to_f <=> zoom.to_f) + 1]
        send(zoom_mode, zoom, input_offset)
      end
    end

    class Result
      attr_reader :source, :dimensions, :frame_rect

      def initialize(source:, dimensions:, frame_rect:)
        @source, @dimensions, @frame_rect = VP::Sprites::Source.new(bounds: source), dimensions, frame_rect
      end

      def bounds
        # so at this point, I think we are expecting the sprite to fit within
        # frame_rect. so this is just for centering small sprites
        frame_rect_x = frame_rect.position.x + [(frame_rect.dimensions.w - dimensions.w)/2, 0].max
        frame_rect_y = frame_rect.position.y + [(frame_rect.dimensions.h - dimensions.h)/2, 0].max

        position = vec2(frame_rect_x, frame_rect_y)
        VP::Rect.new(position: position, dimensions: dimensions)
      end

      def to_h
        {
          bounds: bounds,
          source: source,
        }
      end
    end
  end
end
