require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

require 'tide'
require 'test/unit'

include Tide

DEFAULT_LOCATION = "Galveston Pleasure Pier, Gulf Of Mexico, Texas"

class TideTest < Test::Unit::TestCase
  
  def test_tide_path
    assert_not_nil(TidePath.get)
  end
  
  def test_tide_fatal_exception
    assert_raise(TideFatalException) {Tide.execute(" -l")}
  end
  
  def test_tide_list
    assert_not_nil(Tide.list)
  end
  
  def test_tide_about
    assert_raise(TideFatalException) {Tide.about("unknown")}
    assert_not_nil(Tide.about(DEFAULT_LOCATION))
  end
  
  def test_tide_plain
    assert_not_nil(Tide.plain(DEFAULT_LOCATION))
  end
  
  def test_tide_medium_rare
    assert_not_nil(Tide.medium_rare(DEFAULT_LOCATION))
  end
  
  def test_tide_stats
    assert_not_nil(Tide.stats(DEFAULT_LOCATION))
  end
  
end
