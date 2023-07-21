module AssetWorkspace
  class AssetForm
    include Pushy::Helpers
    include Layout::Helpers
    include Components::Helpers

    attr_reader :pack

    def initialize(pack = nil)
      @pack = pack
      # asset_updatedß!
      # save_assetß!
    end

    def asset›
      return @_asset› if @_asset›
      @_asset› = observable
      asset_from_path›.register(@_asset›)
      @_asset›
    end

    def start_with!(sheet)
      path_field.set_text sheet.path
      path_field.text_input.enter!(sheet.path)
    end

    def layout_component
      @_layout_component ||= column(
        path_field.layout_component,
        # row(
        #   tile_w_field.layout_component,
        #   tile_h_field.layout_component,
        #   component(save_button.layout_component, bounds: quick_bounds(x: 45)),
        # ).tap { |r| r.lookup.name = "sheet tile dimensions" },
        # component(name_field.layout_component, bounds: quick_bounds(y: 4)),
        bounds: quick_bounds(y: 10)
      )
    end

    def renderables
      layout_component.renderables
    end
    #
    # def asset_updatedß!
    #   @_asset_updatedß ||= asset›.subscribe do |asset_h|
    #     name_field.set_text asset_h.asset.name.to_s
    #     tile_w_field.set_text asset_h.asset.tile_size.x.to_s
    #     # tile_h_field.set_text asset_h.asset.tile_h.to_s
    #   end
    # end

    # def save_assetß!
    #   @_save_assetß ||= save_button.click›.chain(
    #     with_latest_from(asset›, name_field.text_state›, tile_w_field.text_state›, tile_h_field.text_state› )
    #   ).subscribe do |(_click, asset_h, text_state, tile_w, tile_h)|
    #     asset_h.asset.name = text_state.text.clone
    #     asset_h.asset.tile_size = vec2(tile_w.text.clone.to_i, tile_w.text.clone.to_i)
    #     # asset_h.asset.tile_h = tile_h.text.clone.to_i
    #     asset_h.asset.save
    #     asset›.next(asset_h)
    #   end
    # end

    def asset_from_path›
      @_asset_from_path› = path_field.enter›.chain(
        changed,
        map do |path|
          sheet = pack.build_sheet(path)
          { asset: sheet }
        end,
        filter { |sa| sa.asset.valid? }
      )
    end

    # def tile_w_field
    #   @_tile_w_field ||= text_field(quick_bounds(w: 85, y: 10, h:50), placeholder: "tile_size")
    # end
    #
    # def tile_h_field
    #   @_tile_h_field ||= text_field(quick_bounds(x: 15, w: 85, y: 10, h:50), placeholder: "tile_w")
    # end

    def path_field
      return @_path_field if @_path_field
      @_path_field = text_field(quick_bounds, placeholder: "path")
      @_path_field.lookup.name = "path field"
      @_path_field
    end

    # def name_field
    #   return @_name_field if @_name_field
    #   @_name_field = text_field(quick_bounds, placeholder: "name")
    #   @_name_field.lookup.name = "name field"
    #   @_name_field
    # end

    # def save_button
    #   @_save_button ||= button("Save")
    # end
  end
end