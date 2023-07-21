module TileWorkspace
  class Widget
    include Pushy::Helpers
    include Layout::Helpers
    include Components::Helpers

    attr_reader :selected_tiles›

    def initialize(selected_tiles›, rect› = nil)
      @selected_tiles› = selected_tiles›
      tilesß!
      saveß!
      show_existing_tilesß!
      last_5_tiles›.next(Assets::Slice.db.records.last(5))
    end

    def saveß!
      @saveß ||= save_button.click›.
        chain(with_latest_from(selected_tiles›)).
        subscribe do |(_click, selected_tiles)|
        selected_tiles.each(&:save)
        last_5_tiles›.next(Assets::Slice.db.records.last(5))
      end
    end

    # def tileß!
    #   @tilesß ||= selected_tiles›.subscribe do |tiles|
    #     if tiles.count == 1
    #       tile_sprite_component.unhide!
    #       tile_sprite.assign!(**(tiles.first.sprite_params))
    #     else
    #       tile_sprite_component.hide!
    #     end
    #   end
    # end

    # def tile_sprite_component
    #   @_tile_sprite_component ||= component(tile_sprite, bounds: quick_bounds(w: 80, h: 80)).hide!
    # end

    # def tile_sprite
    #   @_tile_sprite ||= sprite()
    # end

    module ShowExistingTiles
      def last_5_tiles›
        @_last_5_tiles› ||= observable
      end

      def show_existing_tilesß!
        @show_existing_tilesß ||= last_5_tiles›.subscribe do |tiles|
          library_tile_sprites.preserve.replace(tiles.map do |tile|
            component(
              sprite(**(tile.sprite_params)),
              bounds: quick_bounds(x: 16, w: 64))
          end)
          library_tile_sprites_component.place!
        end
      end

      def library_tile_sprites_component
        @_library_tile_sprites_component ||= row(
          volatile_children: library_tile_sprites,
          bounds: quick_bounds(h: 64, y: 100)
        ) #.hide!
      end

      def library_tile_sprites
        @_library_tile_sprites ||= [].volatile!
      end
    end

    include ShowExistingTiles

    module ShowSelectedTiles
      def tilesß!
        @tilesß ||= selected_tiles›.subscribe do |tiles|
          tile_sprites.preserve.replace(tiles.map do |tile|
            component(
              sprite(**(tile.sprite_params)),
              bounds: quick_bounds(w: 80))
          end)
          tile_sprites_component.place!
        end
      end

      def tile_sprites_component
        @_tile_sprite_component ||= row(
          volatile_children: tile_sprites,
          bounds: quick_bounds(h: 80)
        ) #.hide!
      end

      def tile_sprites
        @_tile_sprites ||= [].volatile!
      end
    end

    include ShowSelectedTiles

    def renderables
      @renderables ||= layout_component.renderables
    end

    def header
      return @_header if @_header
      tlabel = text_label(text: "Tiles", size_enum: 2)
      @_header = component(tlabel, bounds: quick_bounds(h: tlabel.h))
    end

    def layout_component
      @layout_component ||= component(
        column(
          component(solid(color: color(:white)), bounds: quick_bounds(h: 10)),
          # tile_sprite_component,
          tile_sprites_component,
          component(solid(color: color(:white)), bounds: quick_bounds(h: 10)),
          save_button.layout_component,
          header,
          library_tile_sprites_component,
          component(solid(color: color(:white)), bounds: quick_bounds(h: 10)),
          bounds: quick_bounds(anchor: top_left)
        ),
        bounds: quick_bounds(x: 10)
      )
    end

    def active›
      selected_tiles›.chain(
        map do |cords|
          cords && cords.count == 1
        end
      )
    end

    def save_button
      @_save_button ||= button("save")
    end

    private

    attr_reader :rect›, :selected_grid_cords›
  end
end