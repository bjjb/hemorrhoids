require 'forwardable'

module Hemorrhoids
  # A Hemorrhoid restricts the dumping of a table. Its `dump` method expects an
  # array of IDs - it will return tuples of table-names and IDs (uniqed), which
  # will be enought to fetch all information.
  # A Hemorrhoid will use an existing class, if it can find one, to work out the
  # AR associations. Otherwise it will guess from the column names what the
  # associations are supposed to be.
  class Hemorrhoid < Hash

    def initialize(record, options = {})
      super()
      @record = record
      @options = options
      add_self
      add_associated_ids
      hemorrhoids.each do |hemorrhoid|
        merge(hemorrhoid)
      end
    end

    def add_associated_ids
      @record.class.reflect_on_all_associations.each do |association|
        add(association.table_name, ids_for_association(association))
      end
    end

    def add_self
      add(@record.class.table_name, @record.id)
    end

    def add(table, ids)
      self[table] ||= []
      self[table] |= Array(ids)
    end

    def ids_for_association(a)
      send("ids_for_#{a.macro.to_s}_association", a)
    end

    def ids_for_belongs_to_association(a)
      [@record[a.foreign_key]]
    end

    def ids_for_has_many_association(a)
      scope = @record.send(a.name)
      if @options[:limit]
        scope = scope.limit(@options[:limit])
      end
      scope.pluck(:id)
    end

    def ids_for_has_one_association(a)
      @record.send(a.name).try(:id) || []
    end

    def ids_for_has_and_belongs_to_many_association(a)
      scope = @record.send(a.name)
      if @options[:limit]
        scope = scope.limit(@options[:limit])
      end
      scope.pluck(a.association_primary_key)
    end
  end
end
