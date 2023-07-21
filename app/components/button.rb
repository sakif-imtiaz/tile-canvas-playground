module Components
  module Clickable
    include Pushy::Helpers

    def click›
      @click› ||= Services.mouse.clicks.chain(
        with_latest_from(layout_component.rect›),
        filter { |(click, rect)| click.within?(rect) },
        map { |(click, _rect)| click }
      )
    end

    def on_clickß(&blk)
      @on_clickß ||= click›.subscribe do |click|
        blk.call(click)
      end
    end
  end

  class Button
    include VP::Helpers
    include Layout::Helpers
    include Clickable

    PADDING = 12
    MARGIN = 4

    attr_reader :text

    def initialize(text, rect› = nil)
      @text = text
      # layout_component.link! rect› if rect›
    end

    def layout_component
      @layout_component ||= component(
        solid(color: color(:light_gray)),
        component(
          text_label(text: text),
          bounds: quick_bounds(x: PADDING, y: PADDING, w: text_display.w, h: text_display.h)
        ),
        hollow_solid(color: color(:gray)),
        bounds: quick_bounds(y: MARGIN, w: text_display.w + 2*PADDING, h: text_display.h + 2*PADDING)
      )
    end

    def text_display
      @text_display ||= text_label(text: text)
    end

    def renderables
      layout_component.renderables
    end
  end

  module Helpers
    def button(text, rect› = nil)
      Button.new(text, rect›)
    end
    module_function :button
  end
end
