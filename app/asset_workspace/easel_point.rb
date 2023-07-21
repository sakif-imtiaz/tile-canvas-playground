module AssetWorkspace
  class EaselPointCalculator
    def self.from_easel(vs, screen_point)
      new(vs).from_easel(screen_point)
    end

    def initialize(view_settings)
      @vs = view_settings
    end

    private

    def from_easel(screen_point)
      vp = view_point(screen_point)
      vec2(
        (zoom.inverse*vp.x).to_f + source.bounds.position.x,
        (zoom.inverse*vp.y).to_f + source.bounds.position.y)
    end

    attr_reader :vs

    def view_point(screen_point)
      vec2(
        screen_point.x - view_rect.position.x,
        screen_point.y - view_rect.position.y)
    end

    def result
      SpriteSize::Calculator.
        new(vs.asset, vs.frame_rect).
        result(
          zoom: vs.zoom,
          input_offset: vs.drag_offset + vs.offset
        )
    end

    def zoom
      vs.zoom
    end

    def view_rect
      result.bounds
    end

    def source
      result.source
    end
  end
end
