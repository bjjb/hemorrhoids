require 'active_record'
require 'hemorrhoids/hemorrhoid'
require 'hemorrhoids/active_record'
# Hemorrhoids restrict a dump.
#
# A single Hemorrhoid helps inspect database tables and ORM models, to
# determine exactly which tables are related. They can provide a directory of
# related record IDs, which may then be used to restrict a database dump to
# just the associated records.
module Hemorrhoids
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, Hemorrhoids::ActiveRecord)
end

if defined?(Rails)
  require 'hemorrhoids/railtie'
end
