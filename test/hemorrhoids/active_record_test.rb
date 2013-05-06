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
      assert_equal({ :products => [1] }, hemorrhoid.q)
    end

    def test_active_record_hemorrhoids_has_a_map_of_tables_to_classes
      hemorrhoid = Product.first.hemorrhoid
      assert_equal Product, hemorrhoid.active_record(:products)
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
      user = User.create!(:name => 'Stranger')
      hemorrhoid = user.hemorrhoid
      hemorrhoid.process
      assert_equal([user.id], hemorrhoid.r[:users])
      assert_nil hemorrhoid.r[:products]

      product = user.wares.create(:name => 'Buckle')
      hemorrhoid = product.hemorrhoid
      hemorrhoid.process
      assert_equal([user.id], hemorrhoid.r[:users])
      assert_equal([product.id], hemorrhoid.r[:products])

      clothing = Category.find_by_name!('Clothing')
      product.categories << clothing
      hemorrhoid = product.hemorrhoid(:sort => true)
      hemorrhoid.process
      %w[Alice Bob Charlie Stranger].each do |name|
        user = User.find_by_name!(name)
        assert_includes hemorrhoid.r[:users], user.id
        user.wares.each do |product|
          assert_includes hemorrhoid.r[:products], product.id
          product.categories.each do |category|
            assert_includes hemorrhoid.r[:categories], category.id
          end
        end
      end
    end

    def test_join_tables_are_condidered
      kittens = Category.create!(:name => 'Kittens')
      topsy = Product.create!(:name => 'Topsy the kitten')
      topsy.categories << kittens

      hemorrhoid = topsy.hemorrhoid
      hemorrhoid.process
      assert_equal([[kittens.id, topsy.id]], hemorrhoid.r[:categories_products])
    end
  end
end
