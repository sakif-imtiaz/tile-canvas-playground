module Assets
  class Pack
    include Arby::Attributes
    include DB::Persists
    attr_accessor :path, :name

    def self.from_json(hsh)
      new().assign!(**hsh)
    end

    def self.build(path)
      new().tap do |n|
        n.path = path
        n.name = path.split("_").map(&:capitalize).join(" ")
      end
    end

    def full_path
      "assets/#{path}"
    end

    def available_sheet_paths
      depth = full_path.split("/").count
      $gtk.exec("find -L #{full_path} | grep .png | cut -sd / -f #{depth+1}-").split("\n")
    end

    def build_sheet(sheet_path)
      raise "Sheet Absent #{sheet_path}" unless $gtk.stat_file("#{full_path}/#{sheet_path}")
      Sheet.new(path: sheet_path).tap do |sheet|
        sheet.pack_path = full_path
      end
    end

    def to_json; slice(*(db.column_names)).to_json; end

    def self.db_config
      {
        klass: Assets::Pack,
        table_name: "packs",
        column_names: %i(path name),
        primary_keys: :path,
      }
    end
  end
end