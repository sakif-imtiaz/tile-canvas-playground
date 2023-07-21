module AssetWorkspace
  class AssetDisplay
    include Pushy::Helpers
    include VP::Helpers

    def initialize(view_settings›, internal_sprite, view_display, target)
      @view_settings› = view_settings›
      @internal_sprite = internal_sprite
      @target = target
      @view_display = view_display

      @spriteß = self.view_settings›.subscribe do |vs|
        update_internal_sprite!(vs)
        update_target!(vs)
        update_view_display!(vs)
      end
    end

    private

    attr_reader :view_display, :target, :internal_sprite, :view_settings›

    def result(vs)
      SpriteSize::Calculator.
        new(vs.asset, vs.frame_rect).
        result(
          zoom: vs.zoom,
          input_offset: vs.drag_offset + vs.offset
        )
    end

    def update_internal_sprite!(vs)
      internal_sprite.path = vs.asset.full_path
      internal_sprite.bounds = quick_rect(
        0.0, 0.0,
        vs.asset.dimensions.w.to_f,
        vs.asset.dimensions.h.to_f
      )
      internal_sprite.source = VP::Sprites::Source.new(bounds: quick_rect(
        0.0, 0.0,
        vs.asset.dimensions.w.to_f,
        vs.asset.dimensions.h.to_f
      ))
    end

    def update_target!(vs)
      target.h = vs.asset.dimensions.h.to_f
      target.w = vs.asset.dimensions.w.to_f
    end

    def update_view_display!(vs)
      result = result(vs)
      view_display.source = result.source
      view_display.bounds = result.bounds
    end
  end
end
