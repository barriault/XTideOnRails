# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_XTideOnRails_session_id'

  # check for valid date
  def is_day_of_month(year, month, day)
    
    if (month < 1) || (month > 12)
      return false
    end
    
    return (day > 0) && (day <= last_day_of_month(year, month))
  end
  
  # returns the last day of the month accounting for leap year
  def last_day_of_month(year, month)
    month_days = [nil,31,28,31,30,31,30,31,31,30,31,30,31]
    result = month_days[month]
    if is_leap_year(year) && (month == 2)
      result += 1
    end
    return result
  end
  
  # returns true for leap year, false otherwise
  def is_leap_year(year)
    return (((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)) ? true : false
  end

end
