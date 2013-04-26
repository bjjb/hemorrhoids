require 'minitest/autorun'
require 'active_record'
require 'hemorrhoids'

unless ActiveRecord::Base.connected?
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
end

# A small application with some data, for testing with.
module TestApp
  class Product < ActiveRecord::Base
    belongs_to :user
    has_many :comments, :as => :commentable
    has_many :transactions
    has_and_belongs_to_many :categories
    def category_names
      categories.map(&:name)
    end
    def to_s
      name
    end
  end

  class User < ActiveRecord::Base
    has_many :wares, :class_name => "Product"
    has_many :purchases, :class_name => "Transaction", :foreign_key => :buyer_id
    has_many :sales, :through => :wares, :source => :transactions
    has_many :purchased_items, :through => :purchases, :source => :product
    has_many :sold_items, :through => :sales, :source => :product
    has_one :address
    def to_s
      name
    end
  end

  class Address < ActiveRecord::Base
    belongs_to :user
  end

  class Transaction < ActiveRecord::Base
    belongs_to :product
    belongs_to :buyer, :class_name => "User"
    has_many :comments, :as => :commentable
    def to_s
      "#{buyer} bought #{product}"
    end
  end

  class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :commentable, :polymorphic => true
    def to_s
      "#{user}: '#{comment}' (#{commentable})"
    end
  end

  class Category < ActiveRecord::Base
    has_and_belongs_to_many :products
    def to_s
      name
    end
  end

  module ClassMethods
    def create_tables
      create_table(:products, :force => true) do |t|
        t.string :name
        t.integer :quantity
        t.float :price
        t.integer :user_id
        t.timestamps
      end

      create_table(:users, :force => true) do |t|
        t.string :name
        t.timestamps
      end

      create_table(:transactions, :force => true) do |t|
        t.integer :buyer_id
        t.integer :product_id
        t.timestamps
      end

      create_table(:comments, :force => true) do |t|
        t.string :comment
        t.integer :user_id
        t.integer :commentable_id
        t.string :commentable_type
        t.timestamps
      end

      create_table(:categories, :force => true) do |t|
        t.string :name
        t.timestamps
      end

      create_table(:categories_products, :force => true, :id => false) do |t|
        t.integer :category_id
        t.integer :product_id
      end

      create_table(:leftovers, :force => true) do |t|
        t.string :blah
      end

      create_table(:schema_migrations, :force => true) do |t|
        t.string :version
      end

      create_table(:addresses, :force => true) do |t|
        t.string :line1
        t.string :line2
        t.string :line3
        t.string :line4
        t.string :code
        t.string :country
      end
    end

    def create_table(*args, &block)
      ActiveRecord::Base.connection.create_table(*args, &block)
    end

    def create_records
      alice = User.create!(:name => 'Alice')
      anorak = alice.wares.create!(:name => 'Anorak', :quantity => 1, :price => 9.99)
      belt = alice.wares.create!(:name => 'Belt', :quantity => 2, :price => 4.99)
      cap = alice.wares.create!(:name => 'Cap', :quantity => 3, :price => 3)
      anorak.categories << Category.find_or_create_by_name('Clothing')
      belt.categories << Category.find_or_create_by_name('Clothing')
      cap.categories << Category.find_or_create_by_name('Clothing')
      bob = User.create!(:name => 'Bob')
      alpha = bob.wares.create!(:name => 'Alpha Romeo', :quantity => 1, :price => 80000)
      bmw = bob.wares.create!(:name => 'BMW', :quantity => 1, :price => 60000)
      chevy = bob.wares.create!(:name => 'Chevrolet', :quantity => 2, :price => 59999.99)
      alpha.categories << Category.find_or_create_by_name('Automotive')
      bmw.categories << Category.find_or_create_by_name('Automotive')
      chevy.categories << Category.find_or_create_by_name('Automotive')
      charlie = User.create(:name => 'Charlie')
      transaction = Transaction.create!(:buyer => charlie, :product => anorak)
      Comment.create(:commentable => transaction, :user => charlie, :comment => 'This will keep me dry.')
      alpha.comments.create!(:user => charlie, :comment => 'I wish I could afford this.')
    end

    def configure!
      create_tables
      create_records
    end
  end

  def self.included(mod)
    mod.extend(ClassMethods)
    mod.configure!
  end
end
