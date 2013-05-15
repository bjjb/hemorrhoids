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
  end
end
