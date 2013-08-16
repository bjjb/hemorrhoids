require 'test_helper'
require 'hemorrhoids'

describe Hemorrhoids do
  describe "the simplest case" do
    result = Hemorrhoids.dump('sqlite://', :users => [1, 2])
  end
end
