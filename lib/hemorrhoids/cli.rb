require 'optparse'
module Hemorrhoids
  class CLI
    def initialize(args = ARGV.clone)
      @args = args
    end

    def start!
      args = option_parser.order!(args)
      puts "Running Hemorrhoids..."
    end

    def option_parser
      @option_parser ||= OptionParser.new
    end

    def self.usage
      <<-EOF
USAGE: hemorrhoids [options] [description]
      EOF
    end

    def self.start!(args = ARGV.clone)
      new(args).start!
    end
  end
end
