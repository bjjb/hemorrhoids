require 'hemorrhoids/hemorrhoid'
# Hemorrhoids restrict a dump.
#
# A single Hemorrhoid helps inspect database tables and ORM models, to
# determine exactly which tables are related. They can provide a directory of
# related record IDs, which may then be used to restrict a database dump to
# just the associated records.
module Hemorrhoids
end

if defined?(ActiveRecord::Base)
  require 'hemorrhoids/active_record'
end

if defined?(Rails)
  require 'hemorrhoids/railtie'
end
