require 'test/unit'

require 'rubygems'
require 'bundler'

$:.push(File.expand_path('../../lib', __FILE__)) unless $:.include?(File.expand_path('../../lib', __FILE__))
require 'hemorrhoids'

module SampleApp
  class Product < ActiveRecord::Base
    belongs_to :user
    has_many :comments, :as => :commentable
    has_many :transactions
    has_and_belongs_to_many :categories

    def category_names
      categories.map(&:name)
    end
  end

  class User < ActiveRecord::Base
    has_many :wares,      :class_name => "Product"
    has_many :purchases,  :class_name => "Transaction", :foreign_key => :buyer_id
    has_many :sales,      :through => :wares, :source => :transactions
    has_many :purchased_items, :through => :purchases, :source => :product
    has_many :sold_items, :through => :sales, :source => :product
  end

  class Transaction < ActiveRecord::Base
    belongs_to :product
    belongs_to :buyer,  :class_name => "User"
    has_many :comments, :as => :commentable
  end

  class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :commentable, :polymorphic => true
  end

  class Category < ActiveRecord::Base
    has_and_belongs_to_many :products
  end

  def records
    @records ||= {}
  end

  def create_connection
    ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
  end

  def create_tables
    ActiveRecord::Base.connection.create_table(:products, :force => true) do |t|
      t.string :name
      t.integer :quantity
      t.float :price
      t.integer :user_id
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table(:users, :force => true) do |t|
      t.string :name
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table(:transactions, :force => true) do |t|
      t.integer :buyer_id
      t.integer :product_id
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table(:comments, :force => true) do |t|
      t.string :comment
      t.integer :user_id
      t.integer :commentable_id
      t.string :commentable_type
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table(:categories, :force => true) do |t|
      t.string :name
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table(:categories_products, :force => true, :id => false) do |t|
      t.integer :category_id
      t.integer :product_id
    end

    ActiveRecord::Base.connection.create_table(:leftovers, :force => true) do |t|
      t.string :blah
    end

    ActiveRecord::Base.connection.create_table(:schema_migrations, :force => true) do |t|
      t.string :version
    end
  end

  def create_records
    records[:alice] = User.create!(:name => 'Alice')
    records[:anorak] = records[:alice].wares.create!(:name => 'Anorak', :quantity => 1, :price => 9.99)
    records[:belt] = records[:alice].wares.create!(:name => 'Belt', :quantity => 2, :price => 4.99)
    records[:cap] = records[:alice].wares.create!(:name => 'Cap', :quantity => 3, :price => 3)
    records[:anorak].categories << Category.find_or_create_by_name('Clothing')
    records[:belt].categories << Category.find_or_create_by_name('Clothing')
    records[:cap].categories << Category.find_or_create_by_name('Clothing')

    records[:bob] = User.create!(:name => 'Bob')
    records[:alpha] = records[:bob].wares.create!(:name => 'Alpha Romeo', :quantity => 1, :price => 80000)
    records[:bmw] = records[:bob].wares.create!(:name => 'BMW', :quantity => 1, :price => 60000)
    records[:chevy] = records[:bob].wares.create!(:name => 'Chevrolet', :quantity => 2, :price => 59999.99)
    records[:alpha].categories << Category.find_or_create_by_name('Automotive')
    records[:bmw].categories << Category.find_or_create_by_name('Automotive')
    records[:chevy].categories << Category.find_or_create_by_name('Automotive')

    records[:charlie] = User.create(:name => 'Charlie')

    records[:transaction] = Transaction.create!(:buyer => records[:charlie], :product => records[:anorak])
    Comment.create(:commentable => records[:transaction], :user => records[:charlie], :comment => 'This will keep me dry.')

    records[:alpha].comments.create!(:user => records[:charlie], :comment => 'I wish I could afford this.')
  end

  def prepare_database
    create_connection
    create_tables
    create_records
  end
end

module TestHelper
  include SampleApp
  Hemorrhoids.namespace = SampleApp
end

Test::Unit::TestCase.send(:include, TestHelper)
