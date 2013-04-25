require 'test_helper'
require 'hemorrhoids/hemorrhoid'

module Hemorrhoids
  class HemorrhoidTest < MiniTest::Unit::TestCase
    include SampleApp

    def test_hemorrhoid_uses_a_real_class_if_available
      hemorrhoid = Hemorrhoid.new(:products)
      assert hemorrhoid.associations[:users]
    end

    def test_hemorrhoid_gets_all_related_info
      results = Hemorrhoid.new(:products).dump([1])
      assert_equal [:comments, :products, :transactions, :users], results.keys
      assert_equal [1, 2, 3, 4, 5, 6], results[:products]
      assert_equal [1, 2, 3], results[:users]
      assert_equal [1], results[:transactions]
      assert_equal [1, 2], results[:comments]
    end
  end
end
