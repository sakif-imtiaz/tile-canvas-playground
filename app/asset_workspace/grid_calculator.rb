module AssetWorkspace
  class GridCalculator
    include VP::Helpers
    attr_reader :tile_size, :asset

    def initialize(tile_size)
      @tile_size = tile_size.with_f
      @asset = asset
    end

    def grid_pt(easel_pt)
      vec2(
        (easel_pt.x*(1.0/tile_size.w)).floor,
        (easel_pt.y*(1.0/tile_size.h)).floor
      )

    end

    def on(easel_pt)
      VP::Rect.new(
        position: (grid_pt(easel_pt)).floor,
        dimensions: point(1, 1)
      )
    end

    def within(easel_rect)
      cer = easel_rect.canonical
      single = point(1, 1)
      gp1 = grid_pt(cer.position)
      gp2 = grid_pt(point(cer.x + cer.w, cer.y + cer.h))
      gd = gp2 - gp1
      VP::Rect.new(
        position: (gp1 + single),
        dimensions: (gd - single))
    end


    def touching(easel_rect)
      cer = easel_rect.canonical
      single = point(1, 1)
      gp1 = grid_pt(cer.position)
      gp2 = grid_pt(point(cer.x + cer.w, cer.y + cer.h))
      gd = gp2 - gp1
      VP::Rect.new(
        position: (gp1),
        dimensions: (gd + single))
    end
    #
    # def canonical(rect)
    #   c_x, c_x_w = [rect.x, rect.x + rect.w].sort
    #   c_y, c_y_h = [rect.y, rect.y + rect.h].sort
    #
    #   VP::Helpers.quick_rect(c_x, c_y, c_x_w - c_x, c_y_h - c_y)
    # end
  end

  # CELL_SIZE = 8
  #
  # class CoordinateCalculation
  #   private attr_reader :current_drag, :config
  #   def zoom; CELL_SIZE; end
  #   def offset; config.offset; end # change to #position
  #
  #   def initialize(current_drag, rect›)
  #     @current_drag = current_drag
  #   end
  #
  #   def get_coordinates
  #     pixel_coordinates if applicable?
  #   end
  #
  #   def pixel_coordinates
  #     @pixel_coordinates ||= (offset_position * (1.0/CELL_SIZE.to_f)).floor
  #   end
  #
  #   def position
  #     @position ||= if current_drag.p2
  #       vec2(current_drag.p2.x, current_drag.p2.y)
  #     elsif current_drag.p1.x
  #       vec2(current_drag.p1.x, current_drag.p1.x)
  #     end
  #   end
  #
  #   def offset_position
  #     @offset_position ||= (position - offset) if position
  #   end
  #
  #   def in_bounds?
  #     PixelBounds.new(pixel_coordinates, offset_position, config).in_bounds?
  #   end
  #
  #   def applicable?
  #     right_kind? && in_bounds?
  #   end
  #
  #   def right_kind?
  #     (current_drag.p1.x || current_drag.p2.x) &&
  #       # current_drag.btn == :left &&
  #       current_drag.active
  #   end
  #
  #   class PixelBounds
  #     private attr_reader :point, :coordinates, :config
  #
  #     def initialize(coordinates, point, config)
  #       @coordinates, @point, @config = coordinates, point, config
  #     end
  #
  #     def in_circle?
  #       center = (coordinates + vec2(0.5, 0.5))*CELL_SIZE
  #       ((point - center).mag2) < ((CELL_SIZE**2) * 0.25 * 0.86)
  #     end
  #
  #     def in_bounds?
  #       in_rect? && in_circle?
  #     end
  #
  #     def in_rect?
  #       point.x > 0 &&
  #         point.x < config.dimensions.x * CELL_SIZE &&
  #         point.y > 0 &&
  #         point.y < config.dimensions.y * CELL_SIZE
  #     end
  #   end
  # end
end