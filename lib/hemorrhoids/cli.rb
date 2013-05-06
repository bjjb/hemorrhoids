require 'hemorrhoids'
require 'optparse'

module Hemorrhoids
  class CLI < OptionParser
    def initialize(args = ARGV)
      @args = args.dup
      super()
      on('-h', '--help', 'Print this message', :help)
      on('-v', '--verbose', 'Be noisy', :verbose)
      on('-f', '--output FORMAT', 'Set output format (see --formats)', :format)
      on("-F", '--formats', 'List available outputs', :list_formats)
    end

    def help
      puts self
      exit(0)
    end

    def verbose(verbose)
      @verbose = verbose
    end

    def list_formats
      puts "json"
      exit 0
    end

    def on(*args, &block)
      if block_given?
        super
      else
        super(*args.push(&method(args.pop)))
      end
    end

    def start!
      return help if @args.empty?
      order!(@args)
    end

    def self.start!(args = ARGV)
      new(args).start!
    end

    def self.usage
      cli = new
      cli.program_name = 'hemorrhoids'
      cli.to_s
    end
  end
end
