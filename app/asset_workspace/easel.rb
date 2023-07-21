module AssetWorkspace
  class Easel
  include VP::Helpers
  include Pushy::Helpers
  include Layout::Helpers
  include Components::Helpers

  attr_reader :asset›

  def initialize(asset›)
    target
    @asset› = asset›
    asset_display
  end

  def view_settings›
    @view_settings ||= ViewSettings.new(view_inputs.inputs›)
    @view_settings.view_settings›
  end

  # input components
  def view_inputs
    @view_inputs ||= ViewInputs.new(frame_rect›, zoom_field, asset›)
  end

  def asset_display
    # I don't remember ever doing something where I just declare an object,
    # and just by that, I get behavior
    @_asset_display ||= AssetDisplay.new(view_settings›, internal_sprite, view_display, target)
  end

  def zoom_field
    @zoom_field ||= text_field(quick_bounds(y: 10), placeholder: "zoom")
  end

  def frame_rect›
    asset_view.rect›
  end

  def asset_view
    # 1) a. its not a widget yet, so we don't need more from it
    # 1) b. once it is, the way we render it will need to be distinct from
    #       how we define it.
    # 2) is this becoming crazy? we're coming on to an interface for
    #   widgets ‹› component
    #   components ‹› primitives
    # it will soon be time to sort this out

    @asset_view ||= component(
      solid(color: color(:burgundy)),
      view_display,
      bounds: quick_bounds(y: 10, h: 360)
    )
  end

  def target
    @_target ||= Services.register_target(:easel, [internal_sprite])
  end

  def view_display
    return @_view_display if @_view_display
    @_view_display = sprite(path: :easel)
  end

  def internal_sprite
    @_internal_sprite ||= sprite
  end

  def layout_component
    @layout_component ||= column(
      zoom_field.layout_component,
      asset_view,
    )
  end

  def renderables
    layout_component.renderables
  end
  end
end
