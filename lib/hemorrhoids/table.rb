module Hemorrhoids
  # A wrapper for a table, to make it easier to logically jump between models
  # and tables.
  class Table
    attr_reader :name
    attr_accessor :namespace

    def initialize(name, namespace = nil)
      @name, @namespace = name, namespace
    end

    def namespace
      @namespace ||= Hemorrhoids.namespace
    end

    def class_name
      [namespace, name.classify].compact.join('::')
    end

    def klass
      @klass ||= find_or_build_klass
    rescue
      UndescribableTable.new(name)
    end

    def find_or_build_klass
      klass = class_name.constantize
    end

    def count
      @count ||= klass.count
    end

    def hemorrhoid
      @hemorrhoid ||= Hemorrhoid.new(name)
    end

    def connection
      Hemorrhoids.connection
    end

    class UndescribableTable < Table
      def exists?
        @exists ||= connection.table_exists?(name)
      end

      def count
        return 0 unless exists?
        connection.execute("SELECT count(1) FROM #{name}")[0][0]
      end

      def klass
        self.class
      end
    end
  end
end
