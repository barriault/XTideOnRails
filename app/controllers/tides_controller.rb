class TidesController < ApplicationController
  require 'rvg/rvg'
  include Magick
  helper :date
  
  def update
    date = Time.parse(params[:tide][:date])
    lat = params[:lat]
    lng = params[:lng]
    year = date.strftime('%Y').to_i
    month = date.strftime('%m').to_i
    day = date.strftime('%d').to_i
    @location = Location.find(:first, 
        :conditions => [ "latitude = ? && longitude = ?", lat, lng ])
    @chart = @location.get_chart(year, month, day)
    # Generate graph if it doesn't exist.
    @graph = "#{year}/#{month}/#{day}/#{@location.id}.png"
    unless File.exist?("#{RAILS_ROOT}/public/images/#{@graph}")
      width = 425; height = 200
      create_graph(@location, year, month, day, width, height)
    end
  end
  
  def show
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    year = (params[:year] || Time.now.strftime("%Y")).to_i
    month = (params[:month] || Time.now.strftime("%m")).to_i
    day = (params[:day] || Time.now.strftime("%d")).to_i
    
    # Fail on invalid date
    if is_day_of_month(year, month, day)
      # Fail on invalid location
      if @location = Location.find(:first, 
          :conditions => [ "latitude = ? && longitude = ?", lat, lng ])
        @chart = @location.get_chart(year, month, day)
        # Generate graph if it doesn't exist.
        @graph = "#{year}/#{month}/#{day}/#{@location.id}.png"
        unless File.exist?("#{RAILS_ROOT}/public/images/#{@graph}")
          width = 425; height = 200
          create_graph(@location, year, month, day, width, height)
        end
      else
        flash[:error] = "Location at [lat, lng] = [#{params[:lat]}, #{params[:lng]}] was not found."
        flash[:notice] = "You may have mistyped the coordinates."
        render :layout => false, :template => 'shared/error'
      end
    else
      flash[:error] = "Invalid date: #{year}/#{month}/#{day}"
      flash[:notice] = "Please enter a valid date."
      render :layout => false, :template => 'shared/error'
    end
    
  end
  
  private
  
  def create_graph(location, year, month, day, width, height)
    png = create_image(location.get_graph(year, month, day), width, height)
    png.format = "PNG"
    FileUtils.mkdir_p "#{RAILS_ROOT}/public/images/#{year}/#{month}/#{day}"
    png.write("#{RAILS_ROOT}/public/images/#{year}/#{month}/#{day}/#{location.id}.png")
  end

  def create_image(graph, w, h)

    RVG::dpi = 72
  
    yscale = h.to_f / (graph.ubound - graph.lbound)
    ymax = graph.ubound * yscale

    xscale = w.to_f / (graph.points.length - 1)
    xmax = (graph.points.length) * xscale

    y = []
    graph.points.each do |point|
      y << point.y * yscale
    end
    
    x=[]
    0.upto(y.length - 1) do |pointx|
      x << pointx.to_f * xscale
    end
    
    rvg = RVG.new(w, h) do |canvas|
      
      canvas.background_fill = 'white'
      
      window_width = (1.5 * 60 * 60) * (w.to_f / (24 * 60 * 60).to_f)
      
      # show sunrise
      unless graph.sunrise.nil?
        sunrise = get_time_in_seconds(graph.sunrise) * (w.to_f / (24 * 60 * 60).to_f)
        canvas.rect(window_width, h, sunrise - (window_width / 2.0), 0).styles(:fill=>'#FFFF7F', :stroke=>'#FFFF7F', :stroke_width=>1)
        icon = Magick::Image.read("#{RAILS_ROOT}/public/images/sunrise.png").first
        canvas.image(icon, 28, 13, sunrise - 14, h - 12)
        
      end
      
      # show sunset
      unless graph.sunset.nil?
        sunset = get_time_in_seconds(graph.sunset) * (w.to_f / (24 * 60 * 60).to_f)
        canvas.rect(window_width, h, sunset - (window_width / 2.0), 0).styles(:fill=>'#FFFF7F', :stroke=>'#FFFF7F', :stroke_width=>1)
        icon = Magick::Image.read("#{RAILS_ROOT}/public/images/sunset.png").first
        canvas.image(icon, 28, 13, sunset - 15, h - 11)
        
      end
      
      # show moonrise/moonset
      unless graph.moonrise.nil?
        moonrise = get_time_in_seconds(graph.moonrise) * (w.to_f / (24 * 60 * 60).to_f)
      end
      
      unless graph.moonset.nil?
        moonset = get_time_in_seconds(graph.moonset) * (w.to_f / (24 * 60 * 60).to_f)
      end
      
      unless graph.moonrise.nil? && graph.moonset.nil?
        if graph.moonset.nil?
          canvas.rect(w - moonrise + 10, 20, moonrise, 13).styles(:fill=>'gray',:stroke=>'gray', :stroke_width=>1).round(10)
        elsif graph.moonrise.nil?
          canvas.rect(moonset + 10, 20, -10, 13).styles(:fill=>'gray',:stroke=>'gray', :stroke_width=>1).round(10)
        elsif moonrise < moonset
          canvas.rect(moonset - moonrise, 20, moonrise, 13).styles(:fill=>'gray',:stroke=>'gray', :stroke_width=>1).round(10)
        else
          canvas.rect(w - moonrise + 10, 20, moonrise, 13).styles(:fill=>'gray',:stroke=>'gray', :stroke_width=>1).round(10)
          canvas.rect(moonset + 10, 20, -10, 13).styles(:fill=>'gray',:stroke=>'gray', :stroke_width=>1).round(10)
        end
      end
           
      # show the moon phase 0 = don't draw, 1 = new, 2 = first quarter, 3 = full, 4 = last quarter
      images = [nil, "newmoon.png", "firstquarter.png", "fullmoon.png", "lastquarter.png"]
      phase = graph.moon_phase
      unless phase == 0
        icon = Magick::Image.read("#{RAILS_ROOT}/public/images/#{images[phase]}").first
        canvas.image(icon, 46, 46, w - 46, 0)
      end
      
     # plot tick marks for half hours
      scale = w.to_f / 48.0
      len = h * 0.025
      1.upto(47) do |tick|
        pos_x = tick * scale
        canvas.line(pos_x, h, pos_x, h - len).styles(:stroke=>'black', :stroke_width=>1)
       end
                                            
     # plot tick marks for hours
      scale = w.to_f / 24.0
      len = h * 0.05
      1.upto(23) do |tick|
        pos_x = tick * scale
        canvas.line(pos_x, h, pos_x, h - len).styles(:stroke=>'black', :stroke_width=>1)
       end
                                            
      # plot the 3, 6, 9, 12, 15, 16, 18, 21 time marks along bottom
      scale = w.to_f / 8.0
      len = h * 0.1
      1.upto(7) do |tick|
        pos_x = tick * scale
        canvas.line(pos_x, h, pos_x, h - len).styles(:stroke=>'black', :stroke_width=>1)
        txt = (tick * 3).to_s
        txt = "Noon" if txt == "12"
        txt = "3" if txt == "15"
        txt = "6" if txt == "18"
        txt = "9" if txt == "21"
        canvas.text(pos_x, h - (len * 1.25), txt).styles(:font_size => len, :text_anchor => 'middle')
      end
      
      # TODO plot fishing probability
      
      # plot curve and translate to cartesian coordinates
      canvas.g.translate(0, ymax).scale(1, -1) do |plot|
        plot.line(0, 0, xmax, 0).styles(:stroke=>'gray', :stroke_width=>1)
        plot.polyline(x, y).styles(:fill=> 'none', :stroke=>'blue', :stroke_width=>4)
      end
      
    end
    
    return rvg.draw
  end
  
  def get_time_in_seconds(time)
    hr = time.strftime("%H").to_f
    min = time.strftime("%M").to_f
    sec = time.strftime("%S").to_f
    return (hr * 60.0 * 60.0) + (min * 60.0) + sec
  end
  
end
