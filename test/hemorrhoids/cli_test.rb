require 'test_helper'
require 'forwardable'
require 'hemorrhoids/cli'

module Hemorrhoids
  class CLITest < MiniTest::Unit::TestCase

    class CLI < ::Hemorrhoids::CLI
      extend Forwardable
      delegate :puts => :stdout
      delegate :print => :stdout
      def stdout
        @stdout ||= StringIO.new
      end

      attr_accessor :load_rails
      def load_rails?
        !!@load_rails
      end
    end

    @@usage = <<-EOF
Usage: hemorrhoids [options]
    -h, --help                       Print this message
    -v, --verbose                    Be noisy
    -f, --output-format FORMAT       Set output format (see --formats)
    -F, --formats                    List available outputs
    EOF

    def test_cli_help
      assert_equal @@usage, execute
      assert_equal @@usage, execute('-h')
      assert_equal @@usage, execute('--help')
    end

    def test_cli_verbose_flag
      %w(-v --verbose).each do |flag|
        cli = CLI.new([flag])
        cli.start!
        assert cli.verbose?
      end
    end

    def test_list_formats
      assert_equal "json, yaml\n", execute("-F")
      assert_equal "json, yaml\n", execute("--formats")
    end

    def test_set_output_format_to_json
      cli = CLI.new(["-f", "json"])
      cli.start!
      assert_equal "json", cli.output_format
      cli = CLI.new(["--output-format", "json"])
      cli.start!
      assert_equal "json", cli.output_format
    end

    def test_loading_environment
      cli = CLI.new(["-v", "Product"])
      cli.load_rails = true
      cli.start!
    end

  private
    def execute(commandline = "")
      cli = CLI.new(commandline.split(/\s+/))
      cli.start!
      cli.stdout.string
    end
  end
end
