module Hemorrhoids
  class Hemorrhoid

    def initialize(record, options = {})
      @hash = {}

      @record = record
      @options = options

      add_self
      add_associated_ids unless added_associated_ids?

      iterate!
    end

    def add_associated_ids
      @record.class.reflect_on_all_associations.each do |association|
        add(association.table_name, ids_for_association(association))
      end
    end

    def iterate!
      each do |table, ids|
        klass = class_for(table)
        Hemorrhoid.new(klass.find(id))
      end
    end

    def class_for(table)
      @classes ||= {}
      @classes[table] ||= [@options.namespace, table.singularize.classify].flatten.join('::').constantize
    end

    def add_self
      add(@record.class.table_name, @record.id)
    end

    def add(table, ids)
      ids = Array(ids)
      @hash[table] ||= []
      @hash[table] |= ids
      @hash[table].length - ids.length
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
