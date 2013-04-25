require 'hemorrhoids/collector'
require 'hemorrhoids/table'
require 'hemorrhoids/association'

module Hemorrhoids
  # A Hemorrhoid restricts the dumping of a table. Its `dump` method expects an
  # array of IDs - it will return tuples of table-names and IDs (uniqed), which
  # will be enought to fetch all information.
  # A Hemorrhoid will use an existing class, if it can find one, to work out the
  # AR associations. Otherwise it will guess from the column names what the
  # associations are supposed to be.
  class Hemorrhoid
    attr_reader :namespace, :table

    # Create a new Hemorrhoid around a particular table.
    def initialize(table, options = {})
      @options = options
      @table = Table.new(table)
    end

    def klass
      @klass ||= @table.klass
    end

    def associations
      @associations ||= klass.reflect_on_all_associations.map do |association|
        Association.new(association)
      end
    end

    def hemorrhoids
      @hemorrhoids ||= associations.map(&:hemorrhoid)
    end

    def dump(ids, options = {})
      ids = Array(ids).map(&:to_i)
      @results ||= {}
      @results[@table.name] ||= []
      @results[@table.name] += ids
      associations.each do |association|
        results = association.dump(ids, options[association.name] || {})
        @results.deep_merge!(results)
      end
      results
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

    def to_s
      s = "#{klass.name}: #{associations.map(&:to_s).join('; ')}"
    end

  end
end
