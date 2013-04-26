require 'test_helper'
require 'hemorrhoids/association'

module Hemorrhoids
  class AssociationTest < MiniTest::Unit::TestCase
    include TestApp

    def test_associations_are_on_models
      assert_kind_of Association, Product.hemorrhoid.associations.first
    end

    def test_belongs_to_association_returns_the_ids_of_the_associated_records
      result = Product.first.hemorrhoid.associations.find { |a| a.name == :user }.to_hash([1])
      assert_equal %w[users], result.keys
      assert_equal [1], result['users']
    end

    def test_has_many_association_returns_the_ids_of_associated_records

    end
  end
end
