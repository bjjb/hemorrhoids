require 'hemorrhoids/hemorrhoid'
# Hemorrhoids restrict a dump.
#
# A single Hemorrhoid helps inspect database tables and ORM models, to
# determine exactly which tables are related. They can provide a directory of
# related record IDs, which may then be used to restrict a database dump to
# just the associated records.
#
# Once your ORM has Hemorrhoids, you can call `Model::hemorrhoid` to return an
# object that knows how to generate a simple array with tables and IDs, that you
# can then use to extract complete sets of data.
module Hemorrhoids
  @@ignored_tables = ["schema_migrations", "schema_version"]

  # Lists all available tables (according to the AR connection)
  def hemorrhoid_tables
    @tables ||= connection.tables.reject do |table|
      @@ignored_tables.include?(table)
    end.sort
  end

  def hemorrhoid(options = {})
    Hemorrhoid.new(self, options)
  end

  module ClassMethods
    attr_writer :ignored_tables

    def ignored_tables
      @ignored_tables ||= @@ignored_tables
    end
  end

  def Hemorrhoids.included(mod)
    mod.extend ClassMethods
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, Hemorrhoids)
end

require 'hemorrhoids/railtie' if defined?(Rails)
