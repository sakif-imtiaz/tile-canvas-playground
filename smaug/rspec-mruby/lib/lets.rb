module Rspec
  class Let
    attr_reader :prok, :name

    def initialize(memoized = false, memo = nil, prok:, name: "")
      @prok = prok
      @memoized = memoized
      @memo = nil
      @name = name
    end

    def memo
      raise "not memoized" unless memoized?
      @memo
    end

    def clear!
      @memoized = false
    end

    def memoize!(val)
      @memo = val
      @memoized = true
      val
    end

    def memoized?
      @memoized
    end

    def fresh_copy
      Let.new(false, nil, name: name, prok: prok.clone)
    end

    def to_h
      { memoized: @memoized, memo: @memo, name: @name }
    end
  end

  class Lets
    # attr_reader :lets_hash

    def copy
      copied_lets_hash = @lets_hash.reduce({}) do |memo, (name, let)|
        memo[name] = let.fresh_copy
        memo
      end
      Lets.new(copied_lets_hash)
    end

    def initialize(lets_hash = {})
      @lets_hash = lets_hash
    end

    def add_or_replace(name, prok)
      @lets_hash[name] = Let.new(name: name, prok: prok)
    end

    def fetch_let(name)
      @lets_hash[name]
    end

    def let_exists?(m)
      !@lets_hash[m].nil?
    end

    def to_h
      @lets_hash
    end
  end

  module DeclaresLets
    # def lets
    #   @lets ||= (@parent.lets.copy || Lets.new)
    # end

    # def lets
    #   @lets ||= Lets.new
    # end

    def let(name, &blk)
      lets.add_or_replace(name, blk.to_proc)
    end

    def let_value(m)
      _let = lets.fetch_let(m)
      if _let.memoized?
        _let.memo
      else
        calculated = instance_eval(&_let.prok)
        _let.memoize! calculated
        calculated
      end
    end

    def method_missing(m, *args, **kwargs, &block)
      if lets.let_exists?(m)
        let_value(m)
      else
        super(m, *args, **kwargs, &block)
      end
    end
  end
end
