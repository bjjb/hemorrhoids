require 'test_helper'
require 'hemorrhoids/cli'

class Hemorrhoids::CLITest < Test::Unit::TestCase
  include Hemorrhoids

  def test_running_with_help_or_no_options_prints_help
    assert_equal CLI.usage, execute
    assert_equal CLI.usage, execute("-h")
    assert_equal CLI.usage, execute("--help")
  end

private
  def execute(commandline = "")
    lib = File.expand_path("../../../lib", __FILE__)
    exe = File.expand_path("../bin/hemorrhoids", lib)
    `ruby -I#{lib} #{exe} #{commandline}`
  end
end
