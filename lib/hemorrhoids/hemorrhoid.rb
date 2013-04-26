require 'hemorrhoids/collector'
require 'hemorrhoids/association'

module Hemorrhoids
  # A Hemorrhoid restricts the dumping of a table. Its `dump` method expects an
  # array of IDs - it will return tuples of table-names and IDs (uniqed), which
  # will be enought to fetch all information.
  # A Hemorrhoid will use an existing class, if it can find one, to work out the
  # AR associations. Otherwise it will guess from the column names what the
  # associations are supposed to be.
  class Hemorrhoid
    attr_reader :ids

    # Create a new Hemorrhoid around a particular table.
    def initialize(klass, options = {})
      @klass, @table, @options = klass, klass.table_name, options.symbolize_keys
      @ids = @options.delete(:ids) || []

      @hash ||= {}
      @hash[@table] ||= []
      @hash[@table] += @ids
      associations.each do |association|
        @hash.merge! association.to_hash(@ids)
      end
    end

    def to_hash
      hash = { @table => [ids] }
      associations.each do
      end
      hash
    end

    def associations
      @associations ||= @klass.reflect_on_all_associations.map do |association|
        Association.new(association)
      end
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
      s = "#{@klass.name}: #{associations.map(&:to_s).join('; ')}"
    end
  end
end
