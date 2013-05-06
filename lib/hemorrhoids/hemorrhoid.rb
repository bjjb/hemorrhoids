module Hemorrhoids
  # A Hemorrhoid is an object with a queue and a result set. It will refuse to
  # add things to the queue that are already in the result set, and it will
  # dequeue everything in its queue every time you call #step. You pass #step a
  # block which presumably adds some more things to the queue. #process will do
  # this until the queue is empty.
  class Hemorrhoid

    attr_accessor :q, :r, :options

    # Creates a new Hemorrhoid.
    # Options:
    # q:: The initial queue (default is an empty hash)
    # r:: The initial result set (default is an empty hash)
    def initialize(options = {})
      @options = options.symbolize_keys
      @q = @options.delete(:q) || { }
      @r = @options.delete(:r) || { }
    end

    def finished?
      q.empty?
    end

    def enqueue(key, values)
      values = Array(values).uniq
      key = key.to_sym
      values -= r[key] if r[key]
      return if values.empty?
      q[key] ||= []
      q[key] |= values
      q[key].sort! if @options[:sort]
      q.delete(key) if q[key].empty?
    end

    def dequeue(key)
      key = key.to_sym
      q.delete(key)
    end

    def remember(key, values)
      values = Array(values)
      return if values.empty?
      r[key] ||= []
      r[key] |= values
      r[key].sort! if @options[:sort]
    end

    def step(&block)
      q.keys.each do |key|
        values = dequeue(key)
        remember(key, values)
        yield(key, values) if block_given?
      end
    end

    def process(&block)
      step(&block) until finished?
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
  end
end
