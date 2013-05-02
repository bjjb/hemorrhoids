require 'forwardable'
module Hemorrhoids
  # Wraps an ActiveRecord reflection
  class Association
    extend Forwardable

    attr_reader :association, :error

    def initialize(association)
      @association = association
    end

    def_delegators :@association, :klass, :macro, :name, :plural_name,
      :foreign_key, :association_foreign_key, :collection, :active_record,
      :class_name, :table_name, :type

    def valid?
      error.blank?
    end

    def invalid?
      !!valid?
    end

    %w(has_many has_one has_and_belongs_to_many belongs_to).each do |m|
      define_method "#{m}?".to_sym do
        macro == m.to_sym
      end
    end

    def to_s
      "#{macro} #{name}"
    end

    def to_hash(ids = [])
      if belongs_to?
        { plural_name => active_record.where(:id => ids).pluck(foreign_key) }
      elsif has_many?
      elsif has_one?
        raise association.inspect
      elsif has_and_belongs_to_many?
        raise association.inspect
      else
        {}
      end
    end
  end
end
