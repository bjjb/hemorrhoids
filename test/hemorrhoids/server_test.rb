require 'test_helper'
require 'test_app'
require 'hemorrhoids/server'
require 'rack/test'

module Hemorrhoids
  class ServerTest < MiniTest::Unit::TestCase
    include Rack::Test::Methods

    class Server < ::Hemorrhoids::Server
      include TestApp
    end

    def app
      Server.new
    end

    def test_getting_a_record
      skip
      get '/products/1'
      assert last_response.ok?
      assert_match %r|^application/json|, last_response.content_type
      
      data = JSON.parse(last_response.body)
      assert_equal([1,2,3,4,5,6], data['products'].sort)
      assert_equal([1,2,3], data['users'].sort)
      assert_equal([1,2], data['categories'].sort)
      assert_equal([[1,1],[1,2],[1,3],[2,4],[2,5],[2,6]], data['categories_products'].sort)
    end

    def test_getting_several_records
      skip
      get '/categories', :ids => [2, 3]
      assert last_response.ok?
      data = JSON.parse(last_response.body)
      assert_equal([1,2,3], data['categories'].sort)
    end

    def test_dumping_a_record
      skip
      get '/products/1/dump'
      puts last_response.inspect
      assert last_response.ok?
    end
  end
end
