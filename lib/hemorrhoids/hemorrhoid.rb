module Hemorrhoids
  # A Hemorrhoid restricts the dumping of one particular table/model. You give
  # it a table to start from, and some AR conditions, and it can tell you which
  # records are associated.
  class Hemorrhoid
    attr_reader :table
    attr_accessor :conditions

    def initialize(table, conditions = {})
      @table = table.is_a?(Table) ? table : Table.new(table)
      @conditions = conditions
      @class_name = class_name
    end

    def class_name
      @class_name ||= table.class_name
    end

    def klass
      table.klass
    end

    def associations
      @associations ||= klass.reflect_on_all_associations.map do |association|
        Association.new(association)
      end
    end

    def id_cache
      @id_cache ||= Hash.new do |h, k|
        h[k] = []
      end
    end

    def hemorrhoids
      @hemorrhoids ||= associations.map(&:hemorrhoid)
    end

    def has_many_associations
      associations.select(&:has_many?)
    end

    def has_and_belongs_to_many_associations
      associations.select(&:has_and_belongs_to_many?)
    end

    def has_one_associations
      associations.select(&:has_one?)
    end

    def belongs_to_associations
      associations.select(&:belongs_to?)
    end

    def ids
      @ids ||= if klass.respond_to?(:where)
        klass.where(conditions).pluck(:id)
      else
        klass.find(:all, :conditions => conditions, :select => :id).map(&:id)
      end
    end

    def to_s
      s = "#{klass.name}: #{associations.map(&:to_s).join('; ')}"
    end
  end
end
