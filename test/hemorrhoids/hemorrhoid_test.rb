require 'test_helper'
require 'hemorrhoids/hemorrhoid'

module Hemorrhoids
  class HemorrhoidTest < MiniTest::Unit::TestCase
    include TestApp

    def test_hemorrhoid_has_the_right_data
      hemorrhoid = Product.first.hemorrhoid
      assert_equal [1], hemorrhoid['products']
      assert_equal [1], hemorrhoid['users']
      assert_equal [], hemorrhoid['comments']
      assert_equal [1], hemorrhoid['transactions']
    end
  end
end
