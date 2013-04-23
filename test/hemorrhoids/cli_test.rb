require 'test_helper'
require 'hemorrhoids/cli'

class Hemorrhoids::CLITest < Test::Unit::TestCase
  def test_running_with_no_arguments_prints_help
    assert_equal Hemorrhoids::CLI.usage, execute
  end

private
  def execute(commandline = "")
    lib = File.expand_path("../../../lib", __FILE__)
    exe = File.expand_path("../bin/hemorrhoids", lib)
    `ruby -I#{lib} #{exe} #{commandline}`
  end
end
