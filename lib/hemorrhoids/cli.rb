module Hemorrhoids
  class CLI
    def initialize(argv = ARGV, out = $stdout)
      @argv, @out = argv, out
    end

    def run!
    end

    def self.run!
      new.run!
    end
  end
end
