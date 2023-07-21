module Services
  def self.command_processor
    @@_command_processor ||= CommandProcessor
  end
  # module_function :command_processor

  def self.command(nudge, &blk)
    Command.new(nudge, &blk)
  end
  # module_function :command

  class CommandProcessor
    attr_accessor :prev_nudge, :current_command

    def initialize
      @prev_nudge = nil
      @current_command = nil
    end

    def self.instance
      @@_instance ||= CommandProcessor.new
    end

    def self.register(command)
      instance.current_command = command
    end

    def self.tick(_args)
      instance.tick
    end

    def tick
      if @current_command && @current_command.nudge != @prev_nudge
        @prev_nudge = @current_command.nudge
        @current_command.call
      end
    end
  end

  class Command
    attr_reader :tick, :nudge
    def initialize(nudge, &blk)
      @blk = blk
      @nudge = nudge
      register!
    end

    def register!
      CommandProcessor.register(self)
    end

    def call
      @blk.call
    end
  end
end
