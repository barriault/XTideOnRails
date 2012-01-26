require File.dirname(__FILE__) + '/../test_helper'
require 'tides_controller'

# Re-raise errors caught by the controller.
class TidesController; def rescue_action(e) raise e end; end

class TidesControllerTest < Test::Unit::TestCase
  def setup
    @controller = TidesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # This is on the application controller
  def test_is_day_of_month
    assert @controller.is_day_of_month(2007, 7, 22)
    assert !@controller.is_day_of_month(2007, 7, 32)
  end
end
