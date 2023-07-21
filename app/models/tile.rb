# module Assets
#   class Slice
#     include Arby::Attributes
#     include DB::Persists
#     attr_accessor :source_rect, :sheet_path
#
#     def initialize(**kwargs)
#       assign!(**kwargs)
#     end
#
#     def sprite_params
#       {
#         source: VP::Sprites::Source.new(bounds: source_rect),
#         path: sheet_path
#       }
#     end
#
#     # def terrain?; !!data.terrain; end
#     # def terrain; data.terrain; end
#     #
#     # def animation?; !!data.animation; end
#     # def animation; !!data.animation; end
#     #
#     # class Validator
#     #   attr_reader :tile
#     #   def initialize(tile)
#     #     @tile = tile
#     #   end
#     #
#     #   def category
#     #     terrain? || object? || character?
#     #   end
#     # end
#   end
# end
