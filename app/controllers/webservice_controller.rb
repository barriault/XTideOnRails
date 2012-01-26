class WebserviceController < ApplicationController

  def index
  end

  def tides
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    year = Time.now.strftime("%Y").to_i
    month = Time.now.strftime("%m").to_i
    day = Time.now.strftime("%d").to_i
    
    if location = Location.find(:first, 
          :conditions => [ "latitude = ? && longitude = ?", lat, lng ])
      @chart = Webservice.by_location(location, year, month, day)
    else
      @error = true
      @chart = "ERROR"
    end
    
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render :json => @chart.to_json }
    end
    
  end
  
  private
  
end
