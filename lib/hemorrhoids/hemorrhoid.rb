require 'set'

module Hemorrhoids
  class Hemorrhoid

    attr_accessor :record, :q, :r

    def initialize(options = {})
      @options = options
      @q = { }
      @r = { }
    end

    def finished?
      @q.empty?
    end

    def enqueue(table, ids)
      ids = Array(ids).uniq
      table = table.to_sym
      ids -= @r[table] if @r[table]
      return if ids.empty?
      @q[table] ||= []
      @q[table] |= ids
      @q[table].sort! if @options[:sort]
      @q.delete(table) if @q[table].empty?
    end

    def dequeue(table)
      table = table.to_sym
      @q.delete(table)
    end

    def remember(table, ids)
      ids = Array(ids)
      return if ids.empty?
      @r[table] ||= []
      @r[table] |= ids
      @r[table].sort! if @options[:sort]
    end

    def process
      return if finished?
      tables = q.keys
      tables.each do |table|
        ids = dequeue(table)
        remember(table, ids)
        do_table(table, ids) do |associated_table, ids|
          enqueue(associated_table, ids)
        end
      end
    end

    def do_table(table, ids, &block)
      klass = class_for(table)
      klass.reflect_on_all_associations.each do |association|
        send("do_#{association.macro.to_s}", association, ids, &block)
      end
    end

    def do_belongs_to(association, ids, &block)
      if association.options[:polymorphic]
        return do_belongs_to_polymorphic(association, ids, &block)
      end
      key = association.klass.table_name
      t = association.active_record.table_name
      f = association.foreign_key
      p = association.active_record.primary_key
      l = ids.join(',')
      sql = "SELECT DISTINCT '#{t}'.'#{f}' FROM '#{t}' WHERE '#{t}'.'#{p}' in (#{l})"
      result = association.active_record.connection.execute(sql).map { |r| r[0] }
      yield(key, result)
    end

    def do_belongs_to_polymorphic(association, ids, &block)
      t = association.active_record.table_name
      f = association.foreign_key
      p = association.active_record.primary_key
      type = association.foreign_type
      l = ids.join(',')
      sql = "SELECT DISTINCT '#{t}'.'#{f}', '#{t}'.'#{type}' FROM '#{t}' WHERE '#{t}'.'#{p}' in (#{l}) GROUP BY '#{t}'.'#{type}'"
      association.active_record.connection.execute(sql).each do |r|
        yield(r[1].tableize, r[0])
      end
    end

    def do_has_one(association, ids, &block)
      t = association.table_name
      p = association.association_primary_key
      f = association.foreign_key
      l = ids.join(',')
      sql = "SELECT '#{t}'.'#{p}' FROM '#{t}' WHERE '#{t}'.'#{f}' IN (#{l})"
      result = association.active_record.connection.execute(sql).map { |r| r[0] }
      yield(t, result)
    end

    def do_has_many(association, ids, &block)
      puts association.inspect
      if association.options[:as]
        return do_has_many_polymorphic(association, ids, &block)
      end
      t = association.table_name
      p = association.association_primary_key
      f = association.foreign_key
      l = ids.join(',')
      sql = "SELECT '#{t}'.'#{p}' FROM '#{t}' WHERE '#{t}'.'#{f}' IN (#{l})"
      result = association.active_record.connection.execute(sql).map { |r| r[0] }
      yield(t, result)
    end

    def do_has_many_polymorphic(association, ids, &block)
      t = association.table_name
      p = association.association_primary_key
      f = association.foreign_key
      type = association.type
      l = ids.join(',')
      sql = "SELECT DISTINCT '#{t}'.'#{f}', '#{t}'.'#{type}' FROM '#{t}' WHERE '#{t}'.'#{p}' in (#{l}) GROUP BY '#{t}'.'#{type}'"
      association.active_record.connection.execute(sql).each do |r|
        yield(r[1].tableize, r[0])
      end
    end

    def do_has_and_belongs_to_many(association, ids, &block)
    end

    def class_for(table)
      [@options[:namespace], table.to_s.classify].compact.join('::').constantize
    end
  end
end
