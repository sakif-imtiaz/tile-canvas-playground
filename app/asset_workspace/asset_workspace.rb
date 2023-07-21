module AssetWorkspace
  class Widget
    include Layout::Helpers
    attr_reader :easel, :target, :selection, :asset_form
    def initialize(pack)
      @target = Services.register_target(:easel)
      @asset_form = AssetForm.new(pack)
      @easel = Easel.new(asset_form.asset›)
      @selection = Selection.new(easel.frame_rect›, easel.view_settings›, asset_form.asset›)
    end

    def start_with!(sheet)
      asset_form.start_with!(sheet)
    end

    def selected_tiles›
      selection.selected_tiles›
    end

    def renderables
      @_renderables ||= layout_component.renderables
    end

    def layout_component
      @_layout_component ||= column(
        easel.layout_component,
        asset_form.layout_component
      )
    end
  end
end
