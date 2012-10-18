require File.expand_path('../../test_helper', __FILE__)

module Hemorrhoids
  class TableTest < Test::Unit::TestCase
    def setup
      prepare_database
      Hemorrhoids.namespace = 'SampleApp'
    end

    def test_creating_a_table_works_normally
      #require 'debugger'; debugger
      assert_nothing_raised do
        table = Table.new('users')
        assert_kind_of Table, table
        assert_equal 'SampleApp::User', table.class_name
        assert_equal SampleApp::User, table.klass
        assert table.hemorrhoid
      end
    end

    def test_creating_a_non_existant_table
      assert_nothing_raised do
        table = Table.new('blah')
        assert_kind_of Table::UndescribableTable, table.klass
        assert_equal 0, table.count
      end
    end
  end
end
