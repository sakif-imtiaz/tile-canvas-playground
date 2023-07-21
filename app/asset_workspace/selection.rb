module AssetWorkspace
  class Selection
    include VP::Helpers
    include Pushy::Helpers
    include Layout::Helpers

    attr_reader :vs›, :grid, :asset›

    def initialize(_rect›, vs›, asset›)
      @vs› = vs›
      @asset› = asset›
      target
      reset_on_assetß!
      snapß!
    end

    def tile_size
      @tile_size ||= vec2(32, 16)
    end
    attr_writer :tile_size

    def snapß!
      drag›.chain(
        filter { |(drag, vs)| drag.end? }
      ).subscribe do |(drag, vs)|
        snap!(easel_drag(drag, vs))
      end
    end
    #
    # def asset›
    #   @asset› ||= self.vs›.chain(
    #     filter { |s| s.asset },
    #     map { |s| s.asset },
    #     changed
    #   )
    # end

    def reset_on_assetß!
      @assetß ||= asset›.subscribe do |asset_h|
        @tile_size = asset_h.asset.tile_size if asset_h.asset.tile_size
        @grid = SelectionGrid.new(asset_h.asset, tile_size)
      end
    end

    def drag_rect›
      @drag_rect› ||= drag›.chain(
        map do |(drag, vs)|
          if drag.end?
            quick_rect(0,0,-1,-1)
          else
            easel_drag(drag, vs)
          end
        end
      )
    end

    def drag›
      @drag› ||= Services.mouse.drag›.chain(
        filter { |drag| drag.left? },
        with_latest_from(vs›),
        filter do |(drag, vs)|
          frame_rect = vs.frame_rect
          frame_rect.x < drag.p1.x &&
            (frame_rect.x + frame_rect.w) > drag.p1.x &&
            frame_rect.y < drag.p1.y &&
            (frame_rect.y + frame_rect.h) > drag.p1.y &&
            vs.zoom
        end
      )
    end

    # Calculations

    def easel_drag(drag, vs)
      p1 = EaselPointCalculator.from_easel(vs, drag.p1)
      p2 = EaselPointCalculator.from_easel(vs, drag.p2)
      quick_rect(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y)
    end

    def snap!(rect)
      gcalc = GridCalculator.new(tile_size)
      is_grid_click = gcalc.grid_pt(rect.p1) == gcalc.grid_pt(rect.p2)
      updated = if is_grid_click
        gcalc.on(rect.p1)
      else
        # within = gcalc.within(rect)
        # if (within.w * within.h) == 0
          gcalc.touching(rect)
        # else
        #   within
        # end
      end

      held = Services.typing.held
      grid.clear! unless held.shift? || held.meta?
      (updated.x.to_i...(updated.x.to_i+updated.w.to_i)).to_a.each do |x|
        (updated.y.to_i...(updated.y.to_i + updated.h.to_i)).to_a.each do |y|
          sv = true
          sv = !grid.get(vec2(x,y)).try(:value) if Services.typing.held.meta?
          grid.set(vec2(x,y), sv)
        end
      end

      newlines = grid.lines
      selected_tiles›.next(grid.selected_tiles)
      lines.replace(newlines)
    end

    def selected_tiles›
      @_selected_tiles› ||= observable
    end

    def selection_rect›
      @selection_rect› ||= drag_rect›
    end

    # rendering

    def view_display
      @_view_display ||= component(sprite(path: :easel))
    end

    def target
      @_target ||= Services.register_target(:easel, lines, selection_border.renderables)
    end

    def lines
      @lines ||= []
    end

    def selection_border
      return @selection_border if @selection_border
      @selection_border = component(hollow_solid(color: color(:blue)))
      @selection_border.link!(selection_rect›)
      @selection_border
    end

    def renderables
      view_display.renderables
    end
  end

  class SelectionGrid
    include VP::Helpers
    attr_reader :grid, :g_w, :g_h, :tile_size, :asset

    def initialize(asset, tile_size)
      @tile_size = tile_size
      @asset = asset
      build_grid!(asset)
    end

    def clear!; build_grid!(asset); end

    def lines
      grid.each.with_index.map do |row, x|
        row.each.with_index.map do |cell, y|
          if self.get(vec2(x,y).with_i).try(:value)
            cell_lines = cell.map do |side, has_border|
              if has_border && side != :value
                if side == vec2(1,0).with_i
                  lx = x + 1
                  ly = y
                  lw = 0
                  lh = 1
                elsif side == vec2(0,1).with_i
                  lx = x
                  ly = y + 1
                  lw = 1
                  lh = 0
                elsif side == vec2(-1,0).with_i
                  lx = x
                  ly = y
                  lw = 0
                  lh = 1
                elsif side == vec2(0,-1).with_i
                  lx = x
                  ly = y
                  lw = 1
                  lh = 0
                end

                line(
                  x: lx*tile_size.w,
                  y: ly*tile_size.h,
                  w: lw*tile_size.w,
                  h: lh*tile_size.h,
                  color: color(:turquoise)
                )
              end
            end
            overlay = color(:dark_gray).clone
            overlay.a = 80
            cell_lines + [solid(bounds: quick_rect(
              tile_size.w * x,
              tile_size.h * y,
              tile_size.w,
              tile_size.h,
            ),
              color: overlay
            )]
          end
        end
      end.flatten.compact
    end

    def selected_tiles
      grid.each.with_index.map do |row, x|
        row.each.with_index.map do |cell, y|
          if cell.try(:value)
            Assets::Slice.new(
              source_rect: quick_rect(*(
                [x, y, 1, 1].zip([tile_size.w, tile_size.h, tile_size.w, tile_size.h]).
                  map { |c, s| c * s })),
              sheet_path: asset.path,
              pack_path: asset.pack_path
            )
          end
        end
      end.flatten.compact
    end

    def build_grid!(asset)
      @g_w = (asset.dimensions.w/tile_size.w.to_f).ceil.to_i
      @g_h = (asset.dimensions.h/tile_size.h.to_f).ceil.to_i
      @grid = Array.new(g_w+1) { Array.new(g_h+1) }
    end

    def in_bounds?(coord)
      coord.x.between?(0, g_w) &&
        coord.y.between?(0, g_h)
    end

    def set(coords, v)
      return unless in_bounds?(coords)
      (grid[coords.x])[coords.y] = {value: v}
      [-1, 1, 0, 0].zip([0, 0, 1, -1]).
        map {|offset| vec2(*offset).with_i }.
        map {|offset| [offset, (offset + coords).with_i] }.
        filter { |(_offset, ncord)| in_bounds?(ncord) }.
        each do |(offset, ncord)|
        grid[coords.x][coords.y][offset] = (get(ncord).try(:value) ? !v : v)
        if get(ncord).try(:value)
          grid[ncord.x][ncord.y][(offset*-1).with_i] = !v
        end
      end
    end

    def get(coords); grid[coords.x][coords.y]; end
  end
end
