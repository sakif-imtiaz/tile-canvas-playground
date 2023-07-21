module AssetWorkspace
  class ViewInputs
    include Pushy::Helpers

    attr_reader :frame_rect_raw›, :zoom_field, :asset›
    def initialize(frame_rect_raw›, zoom_field, asset›)
      @frame_rect_raw›, @zoom_field = frame_rect_raw›, zoom_field
      @asset› = asset›
    end

    def inputs›
      @_inputs› ||= merge(frame_rect›, zoom›, offset_drag›, asset›)
    end

    def frame_rect›
      @_frame_rect ||= frame_rect_raw›.link(map { |fr| { frame_rect: fr } })
    end

    def zoom›
      @zoom› ||= zoom_field.enter›.chain(
        map { |zoom_txt| Fraction.parse(zoom_txt)},
        filter { |zoom_fraction| zoom_fraction },
        changed,
        map { |z| { zoom: z } }
      )
    end

    def offset_drag›
      @offset_drag› ||= Services.mouse.drag›.chain(
        with_latest_from(frame_rect_raw›),
        filter do |(drag, frame_rect)|
          p1 = {:x=>drag.p1.x, :y=>drag.p1.y, :w=> 1.0, :h=> 1.0 }
          drag.middle? && p1.inside_rect?(frame_rect)
        end,
        map { |(drag, _frame_rect)| { offset_drag: drag } }
      )
    end
  end
end
