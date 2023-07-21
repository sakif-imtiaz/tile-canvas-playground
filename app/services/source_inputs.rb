module Services
  def code_easel_settings›
    SourceInputs::Easel.input›
  end

  def code_easel_settings
    SourceInputs::Easel.instance
  end

  module_function :code_easel_settings›, :code_easel_settings

  module SourceInputs
    class Base
      include Pushy::Helpers
      attr_reader :input›

      def self.instance; @@_instance ||= new; end
      def self.input›; instance.input›; end

      def initialize
        @source› = observable
        @input› = @source›.
          chain(
            last(2),
            filter { |(current, prev)| prev.changes(current).any? },
            map { |(current, _prev)| current }
          )
      end

      def input_value
        raise "Not Implemented"
      end

      def tick(args)
        @source›.next(input_value)
        input›.next(input_value) if args.state.tick_count == 2
      end
    end

    module InputValue
      def changes(other); (self - other); end

      def -(other); to_a - other.to_a; end

      def to_h; to_a.to_h; end

      def to_a; self.class.attrs.map { |k| [k, send(k)] }; end
    end
  end
end