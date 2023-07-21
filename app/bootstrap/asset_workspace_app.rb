Vec2.prepend(Arby::Vector2)

class App
  include VP::Helpers
  include Pushy::Helpers
  include Layout::Helpers
  include Components::Helpers

  attr_reader :sheet_widget, :tile_widget, :app_rect›, :drag_width

    def pack
      @_pack ||= Asset::Pack.build("time_fantasy")
    end

  def initialize
    setup_services!
    setup_widgets!

    app_rect›.next(quick_rect(10, 10, 960, 600))

    render! layout_component

    sheet_widget.start_with!(initial_sheet)
  end

  def pack
    @_pack ||= Assets::Pack.build("time_fantasy")
  end

  def initial_sheet
    pack.build_sheet("beach_tileset.png")
  end

  def setup_widgets!
    @app_rect› ||= observable
    @sheet_widget ||= AssetWorkspace::Widget.new(pack)
    @tile_widget ||= TileWorkspace::Widget.new(sheet_widget.selected_tiles›)
    @drag_width ||= Components::DragWidth.new(color: color(:red).clone)
    layout_component.link!(app_rect›)
    drag_width.setup!(layout_component.bounds)
  end

  def layout_component
    @_layout_component ||= component(
      row(
        component(sheet_widget.layout_component, bounds: quick_bounds(w: '50%')),
        component(tile_widget.layout_component, bounds: quick_bounds(w: "50% -#{15+Components::DragWidth::THICKNESS}px")),
        drag_width.layout_component,
      ),
      component(hollow_solid(color: color(:black)))
    )
  end

  def setup_services!
    $services_before ||= [Services.mouse, Services.typing, Services.render_target_cache]
    $services_after ||= [Services.primitive_buffer, Services.command_processor]
  end

  def render!(has_renderables)
    Services.primitive_buffer.insert_static has_renderables.renderables
  end

  def perform_tick args
    $services_before.each { |service| service.tick(args) } unless args.state.tick_count == 0

    # shove commands here
    Services.command(1) do
      inputs.tile_size 16
    end

    $services_after.each { |service| service.tick(args) }
  end

  def inputs
    @_inputs ||= Inputs.new(sheet_widget, tile_widget)
  end

  class Inputs
    attr_reader :sheet_widget, :tile_widget
    def initialize(sheet_widget, tile_widget)
      @sheet_widget, @tile_widget = sheet_widget, tile_widget
    end

    def tile_size(sz)
      sheet_widget.selection.tile_size = vec2(sz, sz)
    end

    def tile_w(sz)
      sheet_widget.selection.tile_size.w = sz
    end

    def tile_h(sz)
      sheet_widget.selection.tile_size.h = sz
    end
  end

  # def rect_test
  #   innards = {
  #     small_rect: quick_rect(*([10, 10, 100, 100].map(&:to_f))).to_h.as_rect,
  #     small_rect_ash: %i[x y w h].zip([10, 10, 100, 100].map(&:to_f)).to_h,
  #     inner_point: vec2(10.0,10.0),
  #     inner_point_hash: { x: 10.0, y: 10.0, w: 0.0, h:0.0 }
  #   }
  #   big_rect = quick_rect(*([5, 5, 200, 200].map(&:to_f)))
  #   innards.each do |k, v|
  #     # puts "#{k}.within_rect?(big_rect)  |  #{v.inside_rect?(big_rect)}"
  #     puts "#{v} * 3 = #{ v*3 }     | #{k}"
  #   end
  # end
end
