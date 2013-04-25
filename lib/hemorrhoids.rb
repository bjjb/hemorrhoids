# Hemorrhoids restrict a dump.
#
# A single Hemorrhoid helps inspect database tables and ArtiveRecord models, to
# determine exactly which tables are related. They can provide a directory of
# related record IDs, which may then be used to restrict a database dump to
# just the associated records.
require 'hemorrhoids/class_methods'
module Hemorrhoids
  extend ClassMethods
end
