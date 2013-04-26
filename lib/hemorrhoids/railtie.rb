require 'hemorrhoids'

module Hemorrhoids
  # Extends ActiveRecord::Base with Hemorrhoids
  class Railtie < Rails::Railtie
    # what should we do here? Set up a middleware? Hook into the logger?
  end
end
