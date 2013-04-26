module Hemorrhoids
  # Wraps an ActiveRecord reflection
  class Association
    attr_reader :association, :error

    def initialize(association)
      @association = association
    end

    def macro
      @association.macro
    end

    def name
      @association.name
    end

    def klass
      @klass ||= begin
        @association.klass
      rescue NameError
        @error = $!
        nil
      end
    end

    def valid?
      error.blank?
    end

    def invalid?
      !!valid?
    end

    def table
      @table ||= @association.table_name
    end

    def has_many?
      macro == :has_many
    end

    def has_one?
      macro == :has_one
    end

    def has_and_belongs_to_many?
      macro == :has_and_belongs_to_many
    end

    def belongs_to?
      macro == :belongs_to
    end

    def to_s
      "#{macro} #{name}"
    end

    def to_hash(ids = [])
      if belongs_to?
        { association.plural_name => association.active_record.where(:id => ids).pluck(association.foreign_key) }
      else
        {}
      end
    end
  end
end
