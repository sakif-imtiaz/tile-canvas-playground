module Services
  def primitive_buffer
    @@primitive_buffer ||= PrimitiveBuffer.new
  end

  module_function :primitive_buffer

  class PrimitiveBuffer
    attr_reader :primitives, :static_primitives

    def initialize
      @primitives = []
      @static_primitives = []
    end

    def <<(ary, *elts)
      @primitives << [ary]
      @primitives << elts
    end

    def insert_static(ary)
      comb = soft_flatten(ary)
      @primitives << comb.select { |pr| pr.primitive_marker == :volatile }
      @static_primitives << comb.select { |pr| pr.primitive_marker != :volatile }
    end

    def tick(args)
      # puts "@primitives.count #{@primitives.count}" if @primitives.any?
      # @args = args
      args.outputs.primitives << soft_flatten(@primitives, VP::Volatile).map(&:renderables).flatten #.map do |volatile_contents|
      #   volatile_contents.each
      # end

      # flattened_statics = @static_primitives.flatten

      # Services.render_target_cache.targets[:easel].static_primitives.map(&:to_h).each { |t| puts t.inspect } if flattened_statics.any?
      # args.outputs.static_primitives << flattened_statics[0..5]
      # args.outputs.static_primitives << flattened_statics[7..-1]
      # @static_primitives.flatten.map(&:to_h).each { |t| puts t.inspect }
      args.outputs.static_primitives << @static_primitives.flatten

      # @primitives.clear
      @static_primitives.clear
    end
  end

  def render_target_cache
    RenderTargets.instance
  end

  module_function :render_target_cache

  def register_target(name, *static_primitives)
    RenderTargets.register(TargetSetup.new(name, static_primitives: static_primitives))
  end

  module_function :register_target

  def render_targets
    RenderTargets.instance.targets
  end

  module_function :render_targets

  class RenderTargets
    attr_reader :target_setups, :targets
    def initialize
      @target_setups = {}
      @targets = {}
    end

    def self.instance
      @@_instance ||= RenderTargets.new
    end

    def self.register(target_setup)
      if instance.target_setups[target_setup.name]
        instance.target_setups[target_setup.name].shovel(target_setup.static_primitives)
        instance.target_setups[target_setup.name].setup!($gtk.args)
        return instance.target_setups[target_setup.name]
      end
      instance.target_setups[target_setup.name] = target_setup
      instance.targets[target_setup.name] = target_setup.setup!($gtk.args)
      target_setup
    end

    def tick(args)
      target_setups.each do |name, ts|
        targets[name] = ts.setup!(args)
      end
    end
  end

  class TargetSetup
    include Arby::Attributes
    attr_reader :name, :static_primitives, :w, :h

    def to_h
      slice(:name, :w, :h, :static_primitives)
      #   .merge({
      #   static_primitives: static_primitives.map { |sp| sp }
      # })
    end

    def initialize(name ,static_primitives:[])
      @name, @static_primitives = name, static_primitives
    end

    def setup!(args)
      s = args.render_target(name)
      s.static_primitives << @static_primitives.flatten
      s.h = h if h
      s.w = w if w
      s
    end

    def shovel(*prims)
      if Services.render_targets[name]
        Services.render_targets[name].static_primitives.concat(prims.flatten).uniq!
      end
      @static_primitives.concat(prims)
      @static_primitives.uniq!
    end

    def w=(other)
      get.w= other
      @w = other
    end

    def h=(other)
      get.h= other
      @h = h
    end

    def get
      RenderTargets.instance.targets[name]
    end
  end
end
