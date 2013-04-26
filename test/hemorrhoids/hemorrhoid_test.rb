require 'test_helper'
require 'hemorrhoids/hemorrhoid'

module Hemorrhoids
  class HemorrhoidTest < MiniTest::Unit::TestCase
    include TestApp

    def test_hemorrhoid_can_be_created_with_ids
      assert_equal [1], Hemorrhoid.new(Product, ids: [1]).ids
    end

    def test_hemorrhoid_has_the_right_data
      expected = %w[products users comments transactions categories_products categories].sort
      assert_equal expected, Hemorrhoid.new(Product, ids: [1]).to_hash.keys
    end

    def test_hemorrhoid_has_the_right_associations
      associations = Hemorrhoid.new(Product).associations.map(&:name)
      assert_includes associations, 'user'
      assert_includes associations, 'comments'
      assert_includes associations, 'transactions'
    end
  end
end
