require 'test_helper'
require 'hemorrhoids'

class HemorrhoidsTest < MiniTest::Unit::TestCase
  include TestApp

  def test_app_is_set_up_for_tests
    assert_equal [Transaction.first], User.find_by_name('Charlie').purchases
    assert_equal [Transaction.first], User.find_by_name('Alice').sales
    assert_equal ['Anorak'], User.find_by_name('Charlie').purchased_items.map(&:name)
    assert_includes Transaction.first.comments.map(&:comment), "This will keep me dry."
    assert_includes Product.find_by_name('Alpha Romeo').comments.map(&:comment), "I wish I could afford this."
    assert_equal ['Clothing'], Product.find_by_name('Belt').category_names
  end

  def test_orm_instances_can_return_a_hemorrhoid
    assert TestApp::Product.first.hemorrhoid
  end
end
