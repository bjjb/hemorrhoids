require 'active_record'

module Hemorrhoids
  module ActiveRecord
    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def hemorrhoid(options = {})
      return @hemorrhoid if defined?(@hemorrhoid)
      @hemorrhoid = self.class.hemorrhoid(options)
      @hemorrhoid.enqueue(self.class.table_name, self[self.class.primary_key])
      @hemorrhoid
    end

    class Hemorrhoid < ::Hemorrhoids::Hemorrhoid
      def dump(k, v)
        active_record(k).reflect_on_all_associations.each do |reflection|
          enqueue(reflection.table_name, [1])
        end
      end

      def active_record(table)
        ::ActiveRecord::Base.class_dictionary[table.to_s]
      end

      def process
        super(&method(:dump))
      end
    end

    module ClassMethods
      def class_dictionary
        @class_dictionary ||= ObjectSpace.each_object(Class).select do |k|
          k < self
        end.inject({}) do |dictionary, k|
          dictionary[k.table_name] = k
          dictionary
        end
      end

      def hemorrhoid(options = {})
        Hemorrhoid.new(options.merge(active_record: self))
      end

      unless defined?(subclasses)
        def subclasses
          ObjectSpace.each_object(Class).select { |k| k < self }
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Hemorrhoids::ActiveRecord)
