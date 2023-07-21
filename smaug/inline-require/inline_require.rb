require 'optparse'

module InliningRequires
  class Entry
    SUBSTITUTE_FOR_REQUIRE_PATTERN = /^\s*\#\s*main_root_require/
    REQUIRE_PATTERN = /^\s*require/
    REQUIREABLE = [
      REQUIRE_PATTERN,
      SUBSTITUTE_FOR_REQUIRE_PATTERN
    ]

    attr_reader :line

    def initialize(line)
      @line = line
      @processed = false
    end

    def is_a_require_statement?
      self.class.is_a_require_statement?(line)
    end

    def self.is_a_require_statement?(line)
      REQUIREABLE.any? { |r| line =~ r }
    end

    def requires_a_file_that_also_requires_files?
      File.readlines(path).map.any? do |file_line|
        self.class.is_a_require_statement?(file_line)
      end
    end

    def path
      line.match(/require ["'](.*)["']/)[1]
    end

    def require_line
      line.sub(SUBSTITUTE_FOR_REQUIRE_PATTERN, "require")
    end

    def mark_processed!
      @processed = true
      self
    end

    def is_actually_processed?
      @processed
    end
  end

  class Configuration
    DEFAULT_MAIN_PATH = "./app/main.rb"
    DEFAULT_INLINED_OUTPUT_PATH = "./app/inlined.rb"

    attr_reader :main_path, :inlined_output_path

    def initialize(main_path:, inlined_output_path:)
      @main_path = main_path
      @inlined_output_path = inlined_output_path
    end

    def main_entry
      @_main_entry ||= Entry.new("require '#{main_path}'")
    end

    def inlined_output_filename
      @_inlined_output_filename ||= inlined_output_path.split("/").last
    end

    def matches_inlined_output_path?(path)
      @_iof_matcher ||= %r{#{inlined_output_filename}}
      @_iof_matcher =~ path
    end

    def is_this_file?(path)
      @_this_matcher ||= %r{#{__FILE__}}
      @_this_matcher =~ path
    end
  end

  class Inliner
    attr_accessor :unprocessed_entries, :processed_entries, :config

    def initialize(config)
      @config = config
      @unprocessed_entries = [config.main_entry]
      @processed_entries = []
    end

    def run!
      `touch #{config.inlined_output_path}`
      process!
      export!
    end

    def export!
      File.open(config.inlined_output_path, 'w') do |file|
        processed_entries.each do |entry|
          file.puts entry.require_line
        end
      end
    end

    def process!
      while unprocessed_entries.length > 0
        unprocessed = unprocessed_entries.pop
        next if config.matches_inlined_output_path?(unprocessed.path)
        next if config.is_this_file?(unprocessed.path)
        if unprocessed.is_actually_processed?
          processed_entries.prepend(unprocessed)
        elsif unprocessed.requires_a_file_that_also_requires_files?
          to_queue = requires_nested_within(unprocessed)
          to_queue.push(unprocessed.mark_processed!) unless unprocessed == config.main_entry
          unprocessed_entries.concat to_queue
        else
          processed_entries.prepend(unprocessed)
        end
      end
    end

    def requires_nested_within(parent_entry)
      File.readlines(parent_entry.path).map do |line|
        Entry.new(line)
      end.filter do |entry|
        entry.is_a_require_statement?
      end
    end
  end
end

options = {
  main_path: InliningRequires::Configuration::DEFAULT_MAIN_PATH,
  inlined_output_path: InliningRequires::Configuration::DEFAULT_INLINED_OUTPUT_PATH,
}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby inline_require.rb [options]"

  opts.on("-m", "--main-path MAINPATH", "Path to main.rb (Default: './app/main.rb')") do |main_path|
    options[:main_path] = main_path
  end

  opts.on("-i", "--inlined-output-path INLINEDOUTPUTPATH", "Inlined Output Path (Default: './app/inlined.rb')") do |inlined_output_path|
    options[:inlined_output_path] = inlined_output_path
  end
end.parse!

config = InliningRequires::Configuration.new(**options)

InliningRequires::Inliner.new(config).run!
