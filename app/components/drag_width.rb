module Components
  class DragWidth
    include Layout::Helpers
    include Pushy::Helpers

    THICKNESS = 40

    attr_reader :rx_bounds, :prev_w, :prev_h, :color

    def initialize(color:)
      @color = color
    end
    def setup!(rx_bounds)
      @rx_bounds = rx_bounds
      @prev_w = rx_bounds.bounds.w.clone
      @prev_h = rx_bounds.bounds.h.clone
      @resizeß = drag›.subscribe do |drag|
        if drag.end?
          rx_bounds.w = prev_w + px(drag.rect.w)
          rx_bounds.h = prev_h + px(drag.rect.h)
          @prev_w = prev_w + px(drag.rect.w)
          @prev_h = prev_h + px(drag.rect.h)
        else
          rx_bounds.w = prev_w + px(drag.rect.w) if drag.rect.w
          rx_bounds.h = prev_h + px(drag.rect.h) if drag.rect.h
        end
      end
    end

    def in_bar?(drag)
      @drag_start_rect = handle_bar.current_rect.clone if drag.start?
      p1 = {:x=>drag.p1.x, :y=>drag.p1.y, :w=> 1.0, :h=> 1.0 }
      drag.left? && p1.inside_rect?(@drag_start_rect)
    end

    def drag›
      @drag› ||= Services.mouse.drag›.chain(
        filter { |drag| in_bar?(drag) })
    end

    def drag_handle_rect›
      @drag_handle_rect› ||= drag›.chain(
        map do |drag|
          next_rect = handle_bar.current_rect.clone
          next_rect.current_rect.x = drag.rect.x
          next_rect.current_rect.y = drag.rect.y
        end
      )
    end

    def layout_component
      handle_bar#.link!(drag_handle_rect›)
    end

    def handle_bar
      @handle_bar ||= component(
        solid(color: color), bounds: quick_bounds(w: THICKNESS, h: THICKNESS, y: "100% -#{THICKNESS}px")
      )
    end
  end
end
