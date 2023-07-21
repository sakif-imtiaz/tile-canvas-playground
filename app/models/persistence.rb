module DB
  module Persists
    # extend self

    def self.included(base)
      base.extend ClassMethods
    end

    def save
      db.save(self)
    end

    # def has
    #   # hs = instance_variable_get(:@has)
    #   # instance_variable_set(:@has, build_associations)
    #   # # @_has ||= build_associations
    #   unless class_variable_defined?(:@@_has)
    #     class_variable_set(:@_has, db.build_associations(self))
    #   else
    #     class_variable_get(:@_has)
    #   end
    # end

    # def build_associations
    #   db.build_associations(self)
    # end

    def db
      self.class.db
    end

    module ClassMethods
      def db
        # puts "db_config.klass #{db_config.klass}"
        unless class_variable_defined?(:@@_db)
          class_variable_set(:@@_db, Persistence.for(db_config))
        else
          class_variable_get(:@@_db)
        end
      end

      # def attr_persist(*column_names)
      #   @@_column_names ||= []
      #   @@_column_names.concat column_names
      # end
      #
      # def attr_pk(*pk_column_names)
      #   @@_pk_column_names.concat pk_column_names
      # end
      #
      # def has_many(attr_name, fk:, klass:)
      #   @@_has_many ||= []
      #   @@_has_many << {attr_name: attr_name, fk: fk, klass: klass}
      # end
      #
      # def has_many_local(attr_name, key:, klass:)
      #   @@_has_many_local ||= []
      #   @@_has_many_local << {attr_name: attr_name, key: key, klass: klass}
      # end
      #
      # def belongs_to(attr_name, key:, klass:)
      #   @@_has_many ||= []
      #   @@_has_many << {attr_name: attr_name, key: key, klass: klass}
      # end
    end
  end


  class Persistence
    include CanLookup
    attr_reader :klass, :column_names, :table_name, :primary_keys, :config

    def self.for(config)
      result = Registry.filter do |_item, lookup|
        lookup.tags.include?(:persistence) &&
          lookup.data[:table_name] == config.table_name
      end.first
      return result unless result.nil?

      Persistence.new(config)
    end

    def initialize(config)
      lookup.tags<< :persistence
      lookup.data[:table_name] = config.table_name
      lookup.name = "#{config.table_name}_persistence"
      register
      @klass = config.klass
      @column_names, @table_name = config.column_names, config.table_name
      @primary_keys = [config.primary_keys].flatten
      @config = config
      # register!
    end

    def assert_saveable!(record)
      unless pk_attrs(record).values.all?
        missing_keys = pk_attrs(record).map do |(k,v)|
          k unless v.nil?
        end.compact
        raise "Can't Save #{klass.name} without primary keys: #{missing_keys}"
      end
    end

    def pk_attrs(record)
      record.slice(*primary_keys)
    end

    def save(record)
      assert_saveable!(record)
      # canonical_record = self.ensure(**(pk_attrs(record)))
      # canonical_record.assign!(**record.slice(*column_names))

      # if persisted?
      # else
      #   raise ""
      #   record.id = next_id
      #   records.push record
      # end
      # puts record.to_h

      existing = find_by(pk_attrs(record))
      hash_representation = record.slice(*column_names)
      if existing
        existing.assign!(**hash_representation)
      else
        existing = klass.from_json(**hash_representation)
        records << existing
      end

      json_to_save = records.to_json
      $gtk.write_file(table_file_path, json_to_save)
    end

    def where(**kwargs)
      matching_where = records.select do |record|
        record.slice(*(kwargs.keys)) == kwargs
      end
      matching_where
    end

    def find_by(**kwargs)
      where(**kwargs).first
    end

    def next_id
      records.max_by { |record| record.id }.try(:id).to_i + 1
    end

    def records
      return @_records if @_records
      ensure_file!
      @_records = get_records
      @_records
    end

    def table_file_path
      "db/#{table_file_name}"
    end

    def table_file_name
      "#{table_name}.json"
    end

    def ensure(**kwargs)
      if klass == Assets::Sheet
        puts kwargs
      end
      record = find_by(**kwargs)
      return record if record
      if block_given?
        yield **kwargs
      else
        klass.from_json(**kwargs)
      end
    end

    def get_records
      $gtk.parse_json_file(table_file_path).map do |record_h|
        w_sym = record_h.transform_keys(&:to_sym)
        klass.from_json(**w_sym)
      end
    end

    def ensure_file!
      raise "Table File not found" unless $gtk.stat_file(table_file_path)
      # $gtk.write_file(table_file_path, "[]") unless found
    end

    def build_associations(record)
      config.has.each do |k,v|
        belong_ids = [record.send(v.own_key)].flatten
        owners = self.class.for(v.klass).records.filter do |a_r|
          (belong_ids & ([a_r.send(v.foreign_key)].flatten)).any?
        end
        [k, owners]
      end.to_h
    end
      # [
      #   belongs_to(record),
      #   # belongs_to_many(record),
      #   has_many(record),
      #   # has_many_locals(record)
      # ].reduce({}, :merge)

    # module BelongsTo
    #
    #   def has(record)
    #     config.belongs_to.each do |k,v|
    #       belong_ids = [record.send(v.own_key)].flatten
    #       owners = self.class.for(v.klass).records.filter do |a_r|
    #         (belong_ids & ([a_r.send(v.foreign_key)].flatten)).any?
    #       end
    #       [k, owners]
    #     end.to_h
    #   end
    #
    #   def has_many(record)
    #     config.has_many.each do |k,v|
    #       owner_ids = record.send(v.own_key)
    #       owners = self.class.for(v.klass).records.filter do |a_r|
    #         owner_ids & [a_r.send(v.foreign_key)].flatten
    #       end
    #       [k, owners]
    #     end.to_h
    #   end
    # end

    # include BelongsTo
  end
end

class DummyModel
  def to_json; to_h.to_json; end

  def self.table_name
    "dummies"
  end

  def self.column_names
    %i(id data)
  end

  def self.persistence
    @@_persistence ||= DB::Persistence.for(DummyModel)
  end

  def persistence
    DummyModel.persistence
  end

  def self.ensure(**kwargs)
    persistence.ensure(**kwargs)
  end

  def save
    persistence.save(self)
  end
end
