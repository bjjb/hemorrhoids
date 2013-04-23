require 'optparse'
module Hemorrhoids
  class CLI
    def initialize(args = ARGV.clone)
      @args = args
    end

    def start!
      @args = option_parser.order!(@args)
      quit! option_parser.help if @args.empty?
      hemorrhoids << parse! until @args.empty?
      # use the outputter (set from the CLI) to dump the hemorrhoids...
      puts hemorrhoids.inspect
    end

    def parse!
      # parse @args to build a Hemorrhoid
    end

    def quit(message, code = -1)
      puts message
      exit(code)
    end

    def option_parser
      @option_parser ||= OptionParser.new do |o|
        o.program_name = "hemorrhoids"
      end
    end

    def self.usage
      new.option_parser.help
    end

    def self.start!(args = ARGV.clone)
      new(args).start!
    end
  end
end
