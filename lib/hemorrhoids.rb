require 'hemorrhoids/hemorrhoid'
# Hemorrhoids restrict a dump.
#
# A single Hemorrhoid helps inspect database tables and ORM models, to
# determine exactly which tables are related. They can provide a directory of
# related record IDs, which may then be used to restrict a database dump to
# just the associated records.
#
# Once your ORM has Hemorrhoids, you can call `Model::hemorrhoid` to return an
# object that knows how to generate a simple hash with tables and IDs. The real
# trick, though, is recursively getting hemorrhoids for all these, until all IDs
# have been visited, and you have a complete closed set - perfect for useful
# dumps.
module Hemorrhoids
end

require 'hemorrhoids/railtie' if defined?(Rails)
