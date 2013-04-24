require 'optparse'
module Hemorrhoids
  class CLI < OptionParser
    def initialize(args = ARGV.clone)
      @args = args
      super do |o|
      end
    end

    def start!
      args = order!(args)
    end

    def option_parser
      
    end

    def self.usage
      option_parser.to_s
    end

    def self.option_parser

    end

    def self.start!(args = ARGV.clone)
      new(args).start!
    end
  end
end
