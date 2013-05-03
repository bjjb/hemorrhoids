require 'test_helper'
require 'hemorrhoids/hemorrhoid'

module Hemorrhoids
  class HemorrhoidTest < MiniTest::Unit::TestCase
    include TestApp

    def test_creating_from_a_record_initializes_the_queue
      hemorrhoid = Product.first.hemorrhoid
      assert_equal({ products: [1] }, hemorrhoid.q)
    end

    def test_finishing_logic
      hemorrhoid = Product.first.hemorrhoid
      refute hemorrhoid.finished?
      assert_equal [1], hemorrhoid.dequeue(:products)
      assert hemorrhoid.finished?
    end

    def test_enqueue_does_not_add_existing_ids
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.enqueue(:products, [1])
      assert_equal({ products: [1] }, hemorrhoid.q)
    end

    def test_enqueue_takes_tables_as_strings
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.enqueue('bags', [1, 2])
      assert_equal({ bags: [1, 2], products: [1] }, hemorrhoid.q)
    end

    def test_enqueue_handles_single_ids
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.enqueue(:products, 9)
      assert_equal({ products: [1, 9] }, hemorrhoid.q)
    end

    def test_enqueue_creates_new_keys
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.enqueue(:bags, [1, 2])
      assert_equal({ bags: [1, 2], products: [1] }, hemorrhoid.q)
    end

    def test_enqueue_skips_ids_in_the_results
      hemorrhoid = Hemorrhoid.new
      hemorrhoid.r = { foo: [1, 2, 3] }
      hemorrhoid.enqueue(:foo, [2, 3, 4])
      assert_equal({ foo: [4] }, hemorrhoid.q)
    end

    def test_process_does_nothing_if_finished
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.stub(:finished?, true) do
        hemorrhoid.process
      end
    end

    def test_process_moves_the_queue_to_remembered
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.enqueue(:products, [1, 2, 3])
      hemorrhoid.process
      assert_equal({ products: [1, 2, 3] }, hemorrhoid.r)
    end

    def test_class_for_returns_the_right_class
      hemorrhoid = Hemorrhoid.new(namespace: 'TestApp')
      assert_equal Product, hemorrhoid.class_for('products')
    end

    def test_process_adds_belongs_to_ids_to_the_queue
      hemorrhoid = Product.first.hemorrhoid
      hemorrhoid.process
      assert_equal({ users: [1] }, hemorrhoid.q)
    end

    def test_has_one_association
      hemorrhoid = User.first.hemorrhoid
      hemorrhoid.process until hemorrhoid.finished?
      assert_includes hemorrhoid.r.keys, :addresses
    end

    def test_process_works_on_all_associations
      hemorrhoid = Transaction.first.hemorrhoid(sort: true)
      hemorrhoid.process until hemorrhoid.finished?
      assert_equal([1], hemorrhoid.r[:transactions])
      assert_equal([1, 3], hemorrhoid.r[:users])
      assert_equal([1], hemorrhoid.r[:products])
      assert_equal([1], hemorrhoid.r[:comments])
    end
  end
end
