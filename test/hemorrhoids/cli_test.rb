require 'test_helper'
require 'hemorrhoids/cli'

module Hemorrhoids
  class CLITest < MiniTest::Unit::TestCase

  private
    def execute(commandline = "")
      lib = File.expand_path("../../../lib", __FILE__)
      exe = File.expand_path("../bin/hemorrhoids", lib)
      `ruby -I#{lib} #{exe} #{commandline}`
    end
  end
end
