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
            value = { reflection.foreign_key.to_sym => id, reflection.association_foreign_key.to_sym => record.id }
            yield(reflection.options[:join_table], [value])
          end
          yield(record.class.table_name, record.id)
        end
      end
    end

    class Hemorrhoid < ::Hemorrhoids::Hemorrhoid
      attr_accessor :data

      def self.model_dictionary
        @model_dictionary ||= ObjectSpace.each_object(Class).select do |k|
          k < ::ActiveRecord::Base
        end.inject({}) do |dictionary, k|
          dictionary[k.table_name] = k
          dictionary
        end
      end

      def self.lookup_model(table)
        model_dictionary[table.to_s]
      end

      def self.execute(query)
        connection.execute(query)
      end

      def self.connection
        @connection ||= ::ActiveRecord::Base.connection
      end

      def connection
        @connection ||= self.class.connection
      end

      def lookup_model(table)
        self.class.lookup_model(table)
      end

      def dump?
        !ios.empty?
      end

      def ios
        @ios ||= []
      end

      def handle(k, v)
        enqueue(k, v)
      end

      def process(&block)
        super do |k, v|
          if ar = lookup_model(k)
            ar.hemorrhoids(v, &method(:handle))
          end
        end
      end

      def execute(query)
        self.class.execute(query)
      end

      def dump
        process unless finished?
        dump = []
        r.each do |k, v|
          dump << jsonify(k, v)
        end
        dump
      end

      def jsonify(k, v)
        if c = classify(k)
          jsonify_records(c, v) 
        else
          v.each do |conditions|
            jsonify_row(k, conditions)
          end
        end
      end

      def jsonify_records(klass, v)
        klass.where(:id => v).to_json
      end

      def jsonify_row(k, conditions)
        table = Arel::Table.new(k)
        result = ::ActiveRecord::Base.connection.execute(table.project('*').where(conditions).to_sql)
        result.size
      end

      def models
        ObjectSpace.each_object(Class).select do |k|
          k < ::ActiveRecord::Base
        end
      end

      def classify(k)
        (@classes ||= {})[k] ||= models.find { |m| m.table_name == k.to_s }
      end
    end

    module ClassMethods
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
