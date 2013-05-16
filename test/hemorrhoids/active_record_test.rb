require 'test_helper'
require 'test_app'
require 'hemorrhoids'

module Hemorrhoids
  class ActiveRecordTest < MiniTest::Unit::TestCase
    include TestApp

    def test_active_record_classes_have_subclasses
      assert_equal Product, Product.hemorrhoid.lookup_model('products')
      assert_equal Product, Product.hemorrhoid.lookup_model(:products)
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
      assert_equal({ :products => [1] }, hemorrhoid.q)
    end

    def test_active_record_hemorrhoids_has_a_map_of_tables_to_classes
      hemorrhoid = Product.first.hemorrhoid
    end

    def test_active_record_hemorrhoid_add_all_associated_records
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.process
      Product.reflect_on_all_associations.each do |reflection|
        assert_includes hemorrhoid.r.keys, reflection.table_name.to_sym
      end
    end

    def test_charlie_has_his_comments
      hemorrhoid = User.find_by_name('Charlie').hemorrhoid
      hemorrhoid.process
      assert_equal [1, 2], hemorrhoid.r[:comments]
    end

    def test_a_record_has_no_unrelated_info
      hemorrhoid = Product.find_by_name('Topsy the kitten').hemorrhoid
      hemorrhoid.process
      assert_equal([7], hemorrhoid.r[:products])
      assert_equal([3], hemorrhoid.r[:categories])
      assert_equal([{ :category_id => 3, :product_id => 7 }], hemorrhoid.r[:categories_products])
      assert_equal([:categories, :categories_products, :products], hemorrhoid.r.keys.sort)
    end

    def test_join_tables_are_condidered
      topsy = Product.find_by_name('Topsy the kitten')
      kittens = Category.find_by_name('Kittens')
      hemorrhoid = topsy.hemorrhoid
      hemorrhoid.process
      assert_equal([{ :category_id => 3, :product_id => 7 }], hemorrhoid.r[:categories_products])
    end

    def test_dump_fills_the_hemorrhoids_data
      hemorrhoid = Product.find_by_name('Topsy the kitten').hemorrhoid
      hemorrhoid.process
      hemorrhoid.dump
      expected = { :products => [7], :categories_products => [[3, 7]], :categories => [3] }
      assert_equal expected, hemorrhoid.dump
    end
  end
end
