require 'hemorrhoids/hemorrhoid'
require 'sequel'

# Hemorrhoids restrict a dump.
#
# A single Hemorrhoid helps inspect database tables and ORM models, to
# determine exactly which tables are related. They can provide a directory of
# related record IDs, which may then be used to restrict a database dump to
# just the associated records.
# 
# This top-level module contains some utility methods for building Hemorrhoids
# and processing them.
module Hemorrhoids

  # Extract IDs from the database, mapped to their table names
  # For example
  #
  #    Hemorrhoids.squeeze("mysql://localhost/app_production", users: [1, 2])
  # 
  # might return a Hash like
  #
  #    { authors: [1, 2], books: [1, 2, 3, 4, 5] }
  #
  # where authors have books, and those 5 books belong to one of the authors.
  def self.squeeze(spec, options = {})
    sequel_options = options.delete(:sequel_options) || {}
    schema = options.delete(:schema)
    h = Hemorrhoid.new(options)
    h.db = Sequel.connect(spec, sequel_options)
    h.squeeze
  end

  def self.dump(spec, options = {})
    sequel_options = options.delete(:sequel_options) || {}
    schema = options.delete(:schema)
    h = Hemorrhoid.new(options)
    h.db = Sequel.connect(spec, sequel_options)
    map = h.squeeze
  end
end

if defined?(Rails)
  require 'hemorrhoids/railtie'
end
