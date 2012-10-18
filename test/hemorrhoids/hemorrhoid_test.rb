require File.expand_path('../../test_helper', __FILE__)

module Hemorrhoids
  class HemorrhoidTest < Test::Unit::TestCase
    def setup
      prepare_database
    end

    def test_creation_with_a_table
      table = Table.new('transaction')
      hemorrhoid = Hemorrhoid.new(table)
      assert_equal table, hemorrhoid.table
      assert_equal 'SampleApp::Transaction', hemorrhoid.class_name
    end

    def test_creation_with_a_table_name
      hemorrhoid = Hemorrhoid.new('comment')
      assert_kind_of Table, hemorrhoid.table
      assert_equal 'SampleApp::Comment', hemorrhoid.class_name
    end

    def test_conditions
      hemorrhoid = Hemorrhoid.new('categories', { :name => 'Clothing' })
      expected = SampleApp::Category.all(:conditions => { :name => 'Clothing' }).map(&:id)
      assert_equal expected, hemorrhoid.ids
    end
  end
end
