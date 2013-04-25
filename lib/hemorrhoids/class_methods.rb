require 'hemorrhoids'
module Hemorrhoids
  module ClassMethods
    # Lists all available tables (according to the AR connection)
    def tables
      @tables ||= connection.tables.reject do |table|
        ["schema_migrations", "schema_version"].include?(table)
      end.map { |table| Table.new(table) }
    end

    # Gets all known hemorrhoids
    def hemorrhoids
      @hemorrhoids ||= tables.map(&:hemorrhoid)
    end

    def [](table)
      cache[table]
    end

    def connection
      @connection ||= ActiveRecord::Base.connection
      @connection.reset! unless @connection.active?
      @connection
    end

    def namespace
      @namespace ||= nil
    end

    def namespace=(namespace)
      @namespace = namespace
    end

  private
    def cache
      @cache ||= Hash.new do |hash, k|
        hash[k] = hemorrhoids.find { |hemorrhoid| hemorrhoid.name == k }
      end
    end
  end
end
