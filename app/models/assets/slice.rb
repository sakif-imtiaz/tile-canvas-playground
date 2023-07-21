module Assets
  class Slice
    include Arby::Attributes
    attr_accessor :source_rect, :sheet_path, :pack_path
    include DB::Persists

    def initialize(**kwargs)
      assign!(**kwargs)
    end

    def full_path
      "#{pack_path}/#{sheet_path}"
    end

    def sprite_params
      {
        source: VP::Sprites::Source.new(bounds: source_rect.with_f),
        path: full_path
      }
    end

    def to_json
      {
        source_rect: source_rect.with_i.to_h,
        sheet_path: sheet_path,
        pack_path: pack_path
      }.to_json
    end

    def self.from_json(hsh)
      new(
        source_rect: VP::Rect.from_h(**(hsh.source_rect.to_h.with_syms)),
        sheet_path: hsh.sheet_path,
        pack_path: hsh.pack_path
      )
    end

    def self.db_config
      {
        klass: Assets::Slice,
        table_name: "slices",
        column_names: %i(source_rect sheet_path pack_path),
        primary_keys: %i(source_rect sheet_path pack_path),
        # has: {
        #   klass: Assets::Sheet,
        #   foreign_key: :path,
        #   own_key: :sheet_path
        # }
      }
    end

    # def terrain?; !!data.terrain; end
    # def terrain; data.terrain; end
    #
    # def animation?; !!data.animation; end
    # def animation; !!data.animation; end
    #
    # class Validator
    #   attr_reader :tile
    #   def initialize(tile)
    #     @tile = tile
    #   end
    #
    #   def category
    #     terrain? || object? || character?
    #   end
    # end
  end
end