require 'test_helper'
require 'hemorrhoids/hemorrhoid'

module Hemorrhoids
  class HemorrhoidTest < MiniTest::Unit::TestCase
    def test_creating_a_new_hemorrhoid
      hemorrhoid = Hemorrhoid.new
      assert_equal({}, hemorrhoid.q)
      assert_equal({}, hemorrhoid.r)
    end

    def test_creating_a_hemorrhoid_with_a_q_option
      hemorrhoid = Hemorrhoid.new(q: "Foo")
      assert_equal("Foo", hemorrhoid.q)
    end

    def test_creating_a_hemorrhoid_with_a_r_option
      hemorrhoid = Hemorrhoid.new(r: "Foo")
      assert_equal("Foo", hemorrhoid.r)
    end

    def test_finishing_logic
      hemorrhoid = Hemorrhoid.new
      assert hemorrhoid.finished?
      hemorrhoid.q = "Hello"
      refute hemorrhoid.finished?
      hemorrhoid.q = ""
      assert hemorrhoid.finished?
    end

    def test_enqueue_does_not_add_existing_ids
      hemorrhoid = Hemorrhoid.new
      hemorrhoid.enqueue(:products, [1])
      hemorrhoid.enqueue(:products, [1])
      assert_equal({ products: [1] }, hemorrhoid.q)
    end

    def test_enqueue_accepts_string_as_keys
      hemorrhoid = Hemorrhoid.new
      hemorrhoid.enqueue('bags', [1, 2])
      assert_equal({ bags: [1, 2] }, hemorrhoid.q)
    end

    def test_enqueue_handles_single_ids
      hemorrhoid = Hemorrhoid.new
      hemorrhoid.enqueue(:products, 9)
      assert_equal({ products: [9] }, hemorrhoid.q)
    end

    def test_enqueue_creates_new_keys
      hemorrhoid = Hemorrhoid.new
      hemorrhoid.enqueue(:bags, [1, 2])
      assert_equal({ bags: [1, 2] }, hemorrhoid.q)
    end

    def test_enqueue_skips_values_already_in_the_results
      hemorrhoid = Hemorrhoid.new
      hemorrhoid.r = { foo: [1, 2, 3] }
      hemorrhoid.enqueue(:foo, [2, 3, 4])
      assert_equal({ foo: [4] }, hemorrhoid.q)
    end

    def test_step_does_something_with_everything_in_the_queue
      hemorrhoid = Hemorrhoid.new
      hemorrhoid.q = { foo: %w[a b c], bar: %w[A B C] }
      collector = StringIO.new("")
      hemorrhoid.step do |k, v|
        collector.puts k.to_s + ": " + v.join(', ')
      end
      assert_equal "foo: a, b, c\nbar: A, B, C\n", collector.string
    end

    def test_step_moves_the_queue_to_remembered
      hemorrhoid = Hemorrhoid.new
      hemorrhoid.enqueue(:products, [1, 2, 3])
      hemorrhoid.step
      assert_equal({ products: [1, 2, 3] }, hemorrhoid.r)
    end

    def test_process_will_work_through_the_queue
      hemorrhoid = Hemorrhoid.new(q: { a: [1, 2], b: [5] })
      hemorrhoid.process do |key, values|
        values.each do |value|
          hemorrhoid.enqueue(key, (value + 1) % 10)
        end
      end
      assert_equal([1,2,3,4,5,6,7,8,9,0], hemorrhoid.r[:a])
      assert_equal([5,6,7,8,9,0,1,2,3,4], hemorrhoid.r[:b])
    end

    def test_options_can_be_merged
      hemorrhoid = Hemorrhoid.new(sort: true)
      assert hemorrhoid.options[:sort]
      hemorrhoid.options.merge!(sort: false)
      refute hemorrhoid.options[:sort]
    end

    def test_process_works_on_all_associations
      skip
      hemorrhoid = Transaction.first.hemorrhoid(sort: true)
      hemorrhoid.process until hemorrhoid.finished?
      assert_equal([1], hemorrhoid.r[:transactions])
      assert_equal([1, 3], hemorrhoid.r[:users])
      assert_equal([1], hemorrhoid.r[:products])
      assert_equal([1], hemorrhoid.r[:comments])
    end
  end
end
