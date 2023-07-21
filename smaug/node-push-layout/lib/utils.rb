

class LookupData
  attr_accessor :name, :tags, :data

  def initialize(**kwargs)
    @name = kwargs.name
    @tags = kwargs.tags || []
    @data = kwargs.data || {}
  end
end

module CanLookup
  attr_writer :lookup

  def lookup
    @lookup ||= LookupData.new
  end

  def register
    Registry.register(self)
  end
end

class Registry
  attr_reader :items

  def self.register(v)
    if v.lookup.name
      raise "Name Taken" if find(v.lookup.name)
    end
    items << v
  end

  def self.items
    instance.items
  end

  def self.find(query_name)
    filter do |_item, name, _tags|
      name == query_name
    end.first
  end

  def self.filter
    items.filter do |item|
      yield item, item.lookup.name, item.lookup.tags
    end
  end

  def self.instance
    @@instance ||= new
  end

  def initialize
    @items = []
  end
end

module Utils
  include CanLookup

  def assign!(**kwargs)
    kwargs.each do |k, v|
      send("#{k}=".to_sym, v)
    end
    self
  end
end