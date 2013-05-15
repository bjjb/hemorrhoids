require 'hemorrhoids'
require 'sinatra/base'

module Hemorrhoids
  class Server < Sinatra::Base
    before do
      content_type 'application/json'
    end

    get '/:table/:id' do
      hemorrhoid = ActiveRecord::Hemorrhoid.new
      hemorrhoid.enqueue(String(params['table']), Integer(params['id']))
      hemorrhoid.process
      hemorrhoid.r.to_json
    end

    get '/:table' do
      406 unless params['ids']
      hemorrhoid = ActiveRecord::Hemorrhoid.new
      hemorrhoid.enqueue(String(params['table']), params['ids'].map { |id| Integer(id) })
      hemorrhoid.process
      hemorrhoid.r.to_json
    end

    get '/:table/:id/dump' do
      hemorrhoid = ActiveRecord::Hemorrhoid.new
      hemorrhoid.enqueue(String(params['table']), Integer(params['id']))
      hemorrhoid.dump
      hemorrhoid.r.to_json
    end
  end
end
