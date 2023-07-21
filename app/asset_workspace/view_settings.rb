module AssetWorkspace
  class ViewSettings
    include Pushy::Helpers
    attr_reader :inputs›
    def initialize(inputs›)
      @inputs› = inputs›
      setup_stateß!
    end

    def view_settings›
      @_view_settings› ||= observable
    end

    def view_settings_state
      @_view_settings_state ||= {
        offset: vec2(0,0),
        drag_offset: vec2(0,0),
      }
    end

    def setup_stateß!
      @stateß ||= inputs›.subscribe do |update_h|
        updates_for(update_h).each do |update_slice|
          view_settings_state.merge!(update_slice)
          view_settings›.next(view_settings_state) if state_valid?
        end
      end
    end

    def state_valid?
      %i(asset zoom offset drag_offset frame_rect).all? do |s|
        view_settings_state[s]
      end
    end

    def updates_for(update_h)
      update_h.map do |k, v|
        reducers.send(k, v)
      end
    end

    def reducers
      @_reducer ||= Reducers.new(view_settings_state)
    end

    class Reducers
      attr_reader :state
      def initialize(state)
        @state = state
      end

      def zoom(zoom); { zoom: zoom }; end
      def offset(offset); { offset: offset }; end
      def drag_offset(drag_offset); { drag_offset: drag_offset }; end

      def frame_rect(updated_frame_rect)
        return { frame_rect: updated_frame_rect } unless state.asset
        default_zoom = calculator(state.asset, updated_frame_rect).default_zoom
        {
          asset: state.asset,
          zoom: default_zoom,
          default_zoom: default_zoom,
          offset: vec2(0,0),
          drag_offset: vec2(0,0),
          frame_rect: updated_frame_rect
        }
      end

      def asset(updated_asset)
        return {} if updated_asset.try(:path) == state.asset.try(:path)
        default_zoom = calculator(updated_asset).default_zoom
        {
          asset: updated_asset,
          zoom: default_zoom,
          default_zoom: default_zoom,
          offset: vec2(0,0),
          drag_offset: vec2(0,0),
          frame_rect: state.frame_rect
        }
      end

      def calculator(curr_asset = state.asset, curr_rect = state.frame_rect)
        SpriteSize::Calculator.new(curr_asset, curr_rect)
      end

      def offset_drag(drag)
        return {} unless drag && state.asset

        drag_offset = vec2((-1*state.zoom.inverse*drag.rect.w.to_f).to_f,
          (-1*state.zoom.inverse*drag.rect.h.to_f).to_f)

        if drag.end?
          new_offset = calculator.result(
            zoom: state.zoom,
            input_offset: drag_offset + state.offset
          ).source.bounds.position
          { offset: new_offset, drag_offset: vec2(0,0) }
        else
          { drag_offset: drag_offset }
        end
      end
    end
  end
end