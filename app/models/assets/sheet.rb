module Assets
  class Sheet
    include Arby::Attributes
    # include DB::Persists

    attr_accessor :path, :name, :tile_size, :pack_path

    def initialize(path: nil)
      @path = path
    end

    def full_path
      "#{pack_path}/#{path}"
    end

    def dimensions; @_dimensions ||= calculate_dimensions; end

    def calculate_dimensions
      vec2(pixel_array.w, pixel_array.h)
    end

    def pixel_array
      @pixel_array ||= $gtk.get_pixels(full_path.to_s)
    end

    def valid?
      !!(pixel_array && pixel_array.w && pixel_array.w > 0 && pixel_array.h > 0)
    end

    def ==(other)
      other && (path == other.path)
    end

    alias_method :eql?, :==

    def hash; [self.class, path, pack_path].hash; end

    def to_h
      slice(*(db.column_names))
    end

    def to_s
      to_h.to_s
    end

    def self.from_json(hsh)
      built = new(path: hsh.path)
      built.pack_path = hsh.pack_path
      built.name = hsh.name
      built.tile_size = vec2(hsh.tile_size["w"], hsh.tile_size["h"])
      built
    end

    def to_json; slice(*db.column_names).to_json; end

    def self.db_config
      {
        klass: Assets::Sheet,
        table_name: "sheets",
        column_names: %i(path pack_path name tile_size),
        primary_keys: %i(path pack_path),
        # has: [{
        #   klass: Assets::Slice,
        #   foreign_key: :sheet_path,
        #   own_key: :path
        # },{
        #   klass: Assets::Pack,
        #   foreign_key: :path,
        #   own_key: :pack_path
        # }]
      }
    end
  end
end