module RSpec
  class ExampleGroup
    include Rspec::DeclaresLets

    attr_reader :target

    def initialize(target,parent=nil,&block)
      @target = target
      @parent = parent || NullExampleGroup.new
      @groups = []
      @examples = []
      instance_eval(&block)
    end

    # Attach a new sub example group
    def describe(target,&block)
      @groups << ExampleGroup.new(target,self,&block)
    end

    # Attach a new example to the subgroup
    def it(description=nil, &block)
      description ||= "(no description provided)"
      @examples << Example.new(self, description, &block)
    end

    def its(method, &block)
      @target = @target.send(method)
      it(&block)
    end

    def description
      description = if @target.kind_of?(String)
        " "+@target
      else
        @target.to_s
      end

      [@parent.description,description].join('')
    end

    # Gets all the group examples (including subgroups)
    def examples
      @groups.inject(@examples){ |examples,group| examples + group.examples }
    end

    def local_described_class
      @target if @target.kind_of? Class
    end

    def described_class
      local_described_class || @parent.described_class
    end

    def subject(&block)
      if block
        @subject = block
      elsif @subject
        @subject
      elsif local_described_class
        Proc.new{ local_described_class.new }
      else
        @parent.subject
      end
    end

    def lets
      @lets ||= (@parent.lets.copy || Rspec::Lets.new)
    end

  #   # ---
  #   # Begin Lets Stuff - Lot of Duplicated Stuff for now
  #   # ---
  #   def lets
  #     @lets ||= (@parent.lets.copy || Lets.new)
  #   end
  #
  #   def let(name, &blk)
  #     # puts "--"
  #     # puts "adding a let"
  #     # puts "--"
  #     lets.add_or_replace(name, &blk)
  #   end
  #
  #   def let_value(m)
  #     _let = lets.fetch_let(m)
  #     if _let.memoized?
  #       _let.memo
  #     else
  #       # puts "--"
  #       # puts "calculating let_value"
  #       # puts "--"
  #       calculated = instance_eval _let.blk.call
  #       _let.memoize! calculated
  #       calculated
  #     end
  #   end
  #
  #   def method_missing(m, *args, **kwargs, &block)
  #     if lets.let_exists?(m)
  #       let_value(m)
  #     else
  #       super(m, *args, **kwargs, &block)
  #     end
  #   end
  #   # ---
  #   # End Lets Stuff
  #   # ---
  end
end
