# Hemorrhoids restrict a dump.
#
# A single Hemorrhoid helps inspect database tables and ArtiveRecord models, to
# determine exactly which tables are related. They can provide a directory of
# related record IDs, which may then be used to restrict a database dump to
# just the associated records.
module Hemorrhoids
  autoload :Hemorrhoid, 'hemorrhoids/hemorrhoid'
  autoload :Association, 'hemorrhoids/association'
  autoload :Table, 'hemorrhoids/table'
  autoload :CLI, 'hemorrhoids/cli'

  VERSION = "0.0.1"
  
  # Lists all available tables (according to the AR connection)
  def self.tables
    @tables ||= ActiveRecord::Base.connection.tables.reject do |table|
      ["schema_migrations", "schema_version"].include?(table)
    end.map { |table| Table.new(table) }
  end

  # Gets all known hemorrhoids
  def self.hemorrhoids
    @hemorrhoids ||= tables.map(&:hemorrhoid)
  end

  def self.[](table)
    cache[table]
  end

  def self.connection
    @connection ||= ActiveRecord::Base.connection
    @connection.reset! unless @connection.active?
    @connection
  end

  def self.namespace
    @namespace ||= nil
  end

  def self.namespace=(namespace)
    @namespace = namespace
  end

private
  def self.cache
    @cache ||= Hash.new do |hash, k|
      hash[k] = hemorrhoids.find { |hemorrhoid| hemorrhoid.name == k }
    end
  end
end
