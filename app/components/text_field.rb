
module Focusable
  def focus›
    return @_focus› if @_focus›
    @_focus› = Pushy::Observable.new()
    @_focus›.next(false)
    @_focus›
  end

  # make sure to do this somewhere:
  #   lookup.tags << :focusable
  #   register!

  def focus!
    Registry.
      filter { |_item, lookup| lookup.tags.include? :focusable }.
      each { |item| item.focus›.next(false) }
    focus›.next true
  end
end

module Components
  class TextField
    include VP::Helpers
    include Layout::Helpers
    include Pushy::Helpers
    include CanLookup
    include Focusable

    attr_reader :placement›, :initial_bounds, :initial_text, :placeholder_text

    PADDING = 4

    def initialize(bounds, text: "", placeholder: "")
      @placeholder_text = placeholder
      @initial_text = text
      @initial_bounds = bounds
      @initial_bounds.h = px(text_height + 2*PADDING)
      setup_typing!
      register_lookup!
      setup_focus!
    end

    def register_lookup!
      lookup.tags << :focusable
      register
    end

    def setup_focus!
      @focusß = Services.mouse.clicks.chain(
        with_latest_from(layout_component.rect›),
        filter { |(click, rect)| click.within?(rect) }
      ).subscribe { |_clicked| focus! }
    end

    def setup_typing!
      @typingß = text_state›.subscribe do |state|
        highlight.bounds.x = px(state.selection_offset[:x])
        highlight.bounds.w = px(state.selection_offset[:w])
        cursor.bounds.x = px(state.cursor_offset[:x])
        text_display.text = state.text
        if state.text.try(:length) > 0
          @_placeholder_label.text = ""
        else
          @_placeholder_label.text = placeholder_text
        end
      end
    end

    def highlight
      return @_highlight if @_highlight
      highlight_color = color(:navy_blue).clone
      highlight_color.a = 25
      initial_highlight_bounds = quick_bounds(x: "0px", y:"0px", w:"0px", h: text_height )
      @_highlight = component(solid(color: highlight_color), bounds: initial_highlight_bounds)
    end

    def text_height
      text_display.h
    end

    def cursor
      @_cursor ||= component(
        solid(color: color(:blue)),
        bounds: quick_bounds(
          x: 1, y: 0, w: 2, h: text_height))
    end

    def text_display
      @text_display ||= text_label(text: initial_text)
    end

    def placeholder
      return @_placeholder if @_placeholder
      @_placeholder_label = text_label(
        text: initial_text.length > 0 ? "" : placeholder_text,
        color: color(:slate_gray)
      )
      @_placeholder ||= component(
        @_placeholder_label
      )
    end

    def text_input
      @text_input ||= Services::TextInput.new(focus›: focus›, text:initial_text)
    end

    def set_text(text)
      text_input.text.replace(text)
      text_input.selection = (text.length)...(text.length)
      text_input.emit_state!
    end

    def enter›
      text_input.enter›
    end

    def text_state›
      text_input.state›
    end

    def renderables
      layout_component.renderables
    end

    def layout_component
      @layout_component ||= component(
        component(
          highlight, cursor, text_display, placeholder,
          bounds: quick_bounds(x: PADDING, y: PADDING, h: text_height)
        ),
        hollow_solid(color: color(:gray)),
        bounds: initial_bounds
      )
    end
  end

  module Helpers
    def text_field(bounds, text:"", placeholder: "")
      TextField.new(bounds, text: text, placeholder: placeholder)
    end
  end
end
