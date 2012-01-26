class MapController < ApplicationController

  def index
  end

  def clustered_locations
    ne = params[:ne].split(',').collect{|e|e.to_f}  
    sw = params[:sw].split(',').collect{|e|e.to_f}
  
    # Get all the locations within the bounds. 
    # Need to worry about meridian here.
    if sw[1] < ne[1]
      cond = "(latitude BETWEEN ? and ?) AND (longitude BETWEEN ? and ?)"
      locations = Location.find(:all,
        :select=>['id, latitude, longitude, name, loc_type'],
        :conditions => [cond, sw[0], ne[0], sw[1], ne[1]])
    else
      cond = "(latitude BETWEEN ? and ?) AND (longitude BETWEEN ? and 180.0) OR (longitude BETWEEN -180.0 and ?)"
      locations = Location.find(:all,
        :select=>['id, latitude, longitude, name, loc_type'],
        :conditions => [cond, sw[0], ne[0], sw[1], ne[1]])
    end

    # limit to 30 markers
    max_markers = 30
    lng_span=0
    lat_span=0   
    clustered=Hash.new
    
    logger.debug("Starting clustering: #{locations.length} locations.")
    
    # we'll probably have to loop a few times to get the number of clustered markers
    # below the max_markers value
    loop do  
      # Initially, each cell in the grid is 1/30th of the longitudinal span,
      # and 1/30th of the latitudinal span. With multiple iterations of the loop,
      # the spans get larger (and therefore clusters get more markers)
      lng_span+=(ne[1]-sw[1])/30
      lat_span+=(ne[0]-sw[0])/30
      
      # This is where we're going to be puting the towers we've clustered into groups
      # the key of the hash is the coordinates of the grid cell, 
      # and the value is an array of towers which have been assigned to the cell
      clustered=Hash.new
 
      # we're going to be iterating however many times we need to,
      locations.each do |loc|
        # determine which grid square this marker should be in
        grid_y = ((loc.latitude - sw[0]) / lat_span).floor
        grid_x = ((loc.longitude - sw[1]) / lng_span).floor
        
        # create a new array if it doesn't exist
        key = "#{grid_x}_#{grid_y}"
        (clustered[key] = Array.new) if !clustered.has_key?(key) 
        clustered[key].push(loc)  
      end # end of iterating through each tolocationwer
      
      logger.debug "Current clustering has #{clustered.size} elements."
      break unless clustered.length > max_markers
    end
    
    # At this point we've got max_markers or less points to render.
    # Now, let's go through and determine which cells have multiple markers
    # (which needs to be rendered as a cluster), and which cells have a single marker
    result = Array.new
    clustered.each_value do |loc_array|
      # regardless of whether this is a cluster or an individual, set the coordinates to  
      # the location in the array
      marker = {:id => loc_array[0].id,
                :latitude => loc_array[0].latitude,
                :longitude => loc_array[0].longitude,
                :name => loc_array[0].name,
                :type => loc_array[0].loc_type}

      # here's where we differentiate between clusters and individual markers
      marker[:type] = 'c' if loc_array.size > 1
      result.push(marker)
    end 
      
    render :text => result.to_json
  end
  
end
