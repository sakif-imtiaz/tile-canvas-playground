module RSpec
  class Example
    include RSpec::Matchers::DSL
    include Rspec::DeclaresLets

    PENDING = -> { raise MRubyTestSkip, "(Not implemented)" }
    def initialize(group,description,&block)
      @group = group
      @description = description
      @block = block || PENDING
    end

    def lets
      @lets ||= (@group.lets.copy || Rspec::Lets.new)
    end

    # def let_value(m)
    #   _let = lets.fetch_let(m)
    #   if _let.memoized?
    #     _let.memo
    #   else
    #     # puts "--"
    #     # puts "calculating let_value"
    #     # puts "--"
    #     calculated = instance_eval _let.blk.call
    #     _let.memoize! calculated
    #     calculated
    #   end
    # end
    #
    # def method_missing(m, *args, **kwargs, &block)
    #   if lets.let_exists?(m)
    #     let_value(m)
    #   else
    #     super(m, *args, **kwargs, &block)
    #   end
    # end

    # Executes the example Proc
    def execute
      instance_eval(&@block)
    end

    # The example full description
    def description
      [@group.description,@description].join(' ')
    end

    def expect(*args,&block)
      Expectation.new(*args,&block)
    end

    def described_class
      @group.described_class
    end

    def subject
      @subject ||= @group.subject.call
    end

    def is_expected
      expect(subject)
    end

    def should(*args)
      expect(subject).to(*args)
    end

    def should_not(*args)
      expect(subject).not_to(*args)
    end
  end
end
