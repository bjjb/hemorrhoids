require File.expand_path('../test_helper', __FILE__)

class HemorrhoidsTest < Test::Unit::TestCase
  def setup
    prepare_database
  end

  def test_app_is_set_up_for_tests
    assert_equal [records[:transaction]], records[:charlie].purchases
    assert_equal [records[:transaction]], records[:alice].sales
    assert_equal [records[:anorak]], records[:charlie].purchased_items
    assert records[:transaction].comments.map(&:comment).include?("This will keep me dry.")
    assert records[:alpha].comments.map(&:comment).include?("I wish I could afford this.")
    assert_equal ['Clothing'], records[:belt].category_names
  end

  def test_tables_includes_all_interesting_tables
    names = Hemorrhoids.tables.map(&:name)
    assert names.include?('products')
    assert names.include?('users')
    assert names.include?('transactions')
    assert names.include?('comments')
    assert names.include?('categories')
    assert names.include?('categories_products')
  end

  def test_tables_also_includes_crappy_tables
    names = Hemorrhoids.tables.map(&:name)
    assert names.include?('leftovers')
  end

  def test_schema_tables_are_ignored
    names = Hemorrhoids.tables.map(&:name)
    assert !names.include?('schema_migrations')
  end
end
