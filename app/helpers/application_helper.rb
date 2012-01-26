# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def format_latitude(latitude)
    lat = latitude.to_f
    if lat >= 0
      number_with_precision(lat, 4) + " N"
    else
      number_with_precision(lat.abs, 4) + " S"  
    end
  end
  
  def format_longitude(longitude)
    long = longitude.to_f
    if long >= 0
      number_with_precision(long, 4) + " E"
    else
      number_with_precision(long.abs, 4) + " W"  
    end
  end
  
end
