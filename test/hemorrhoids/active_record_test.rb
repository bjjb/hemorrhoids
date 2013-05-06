require 'test_helper'
require 'test_app'
require 'hemorrhoids'

module Hemorrhoids
  class ActiveRecordTest < MiniTest::Unit::TestCase
    include TestApp

    def test_active_record_classes_have_subclasses
      assert_equal Product, Product.hemorrhoid.active_record('products')
    end

    def test_active_record_base_includes_hemorrhoids
      assert_includes ::ActiveRecord::Base.included_modules, Hemorrhoids::ActiveRecord
    end

    def test_active_record_classes_have_hemorrhoids
      assert_kind_of Hemorrhoids::ActiveRecord::Hemorrhoid, Product.hemorrhoid
    end

    def test_active_records_have_hemorrhoids
      hemorrhoid = Product.first.hemorrhoid
      assert_kind_of Hemorrhoids::ActiveRecord::Hemorrhoid, hemorrhoid
      assert_equal({ products: [1] }, hemorrhoid.q)
    end

    def test_active_record_hemorrhoids_has_a_map_of_tables_to_classes
      hemorrhoid = Product.first.hemorrhoid
      assert_equal Product, hemorrhoid.active_record(:products)
    end

    def test_active_record_hemorrhoid_add_all_associated_records
      skip
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.process
      Product.reflect_on_all_associations.each do |reflection|
        assert_includes hemorrhoid.r.keys, reflection.table_name.to_sym
      end
    end
  end
end
