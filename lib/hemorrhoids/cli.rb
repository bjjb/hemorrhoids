require 'hemorrhoids'
require 'optparse'

module Hemorrhoids
  class CLI

    def initialize(args = ARGV)
      @args = args.dup
      @parser = OptionParser.new do |o|
        o.program_name = "hemorrhoids"
        o.on('-h', '--help', 'Print this message', &method(:help))
        o.on('-v', '--verbose', 'Be noisy', &method(:verbose))
        o.on('-f', '--output-format FORMAT', 'Set output format (see --formats)', &method(:output_format=))
        o.on("-F", '--formats', 'List available outputs', &method(:list_formats))
      end
    end

    def help(*args)
      puts @parser.to_s
      @finish = true
    end

    def verbose(verbose)
      @verbose = verbose
    end

    def list_formats(*args)
      puts output_formats.join(', ')
      @finish = true
    end

    def output_formats
      %w(json yaml)
    end

    def output_format
      @output_format ||= 'json'
    end

    def output_format=(*args)
      format = args.shift
      if output_formats.include?(format)
        @output_format = format
      else
        puts "Unknown output format: #{format}"
      end
    end

    def start!
      @parser.order!(@args)
      return if @finish
      return help if @args.empty?
      load_rails if load_rails?
      puts "This CLI doesn't do anything yet."
    end

    def load_rails?
      return false if defined?(Rails)
      File.exists?(File.expand_path("config/environment.rb"))
    end

    def load_rails
      puts "Loading rails..." if verbose?
      require File.expand_path("config/environment.rb")
    end

    def verbose?
      !!@verbose
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
