require 'active_record'

module Hemorrhoids
  module ActiveRecord
    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def hemorrhoid(options = {})
      hemorrhoid = self.class.hemorrhoid(options)
      hemorrhoid.enqueue(self.class.table_name, self[self.class.primary_key])
      hemorrhoid
    end

    def hemorrhoids(&block)
      self.class.reflect_on_all_associations.each do |reflection|
        Array(send(reflection.name)).each do |record|
          if reflection.macro == :has_and_belongs_to_many
            value = [self, record].sort_by { |r| r.class.table_name }.map(&:id)
            yield reflection.options[:join_table], [value]
          end
          yield(record.class.table_name, record.id)
        end
      end
    end

    class Hemorrhoid < ::Hemorrhoids::Hemorrhoid
      def dump(k, v)
        ar = active_record(k)
        ar.hemorrhoids(v, &method(:enqueue)) unless ar == :join
      rescue => e
        raise "Failed to dump #{k} => #{v.inspect} - #{e}"
      end

      def active_record(table)
        ::ActiveRecord::Base.hemorrhoid_dictionary[table.to_s] || :join
      end

      def process
        super(&method(:dump))
      end
    end

    module ClassMethods
      def hemorrhoid_dictionary
        @hemorrhoid_dictionary ||= ObjectSpace.each_object(Class).select do |k|
          k < self
        end.inject({}) do |dictionary, k|
          dictionary[k.table_name] = k
          dictionary
        end
      end

      def hemorrhoid(options = {})
        Hemorrhoid.new(options.merge(:active_record => self))
      end

      def hemorrhoids(ids, &block)
        return legacy_hemorrhoids(ids, &block) unless respond_to?(:where)
        where(:id => ids).each do |record|
          record.hemorrhoids(&block)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Hemorrhoids::ActiveRecord)
