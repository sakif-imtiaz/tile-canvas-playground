module RSpec

  # Null object to handle example group parents chain
  class NullExampleGroup
    include Rspec::DeclaresLets

    def description
      ""
    end

    def described_class
      nil
    end

    def subject
      Proc.new{
        raise "Subject not defined"
      }
    end

    def lets
      @lets ||= Rspec::Lets.new
    end

    # # ---
    # # Begin Lets Stuff - Lot of Duplicated Stuff for now
    # # ---
    #
    # # Well this one is different

    #
    # def let(name, &blk)
    #   lets.add_or_replace(name, &blk)
    # end
    #
    # def let_value(m)
    #   _let = lets.fetch_let(m)
    #   if _let.memoized?
    #     _let.memo
    #   else
    #     calculated = instance_eval _let.blk.call
    #     _let.memoize! calculated
    #     calculated
    #   end
    # end
    #
    # def method_missing(m, *args, **kwargs, &block)
    #   if lets.let_exists?(m)
    #     lets.fetch_let(m)
    #   else
    #     super(m, *args, **kwargs, &block)
    #   end
    # end
    #
    # # ---
    # # End Lets Stuff
    # # ---
  end

end
