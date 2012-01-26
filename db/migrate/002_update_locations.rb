class UpdateLocations < ActiveRecord::Migration
  def self.up
    Location.find(:all).each do |location|
      UpdateLocations.update(location)
    end
  end

  def self.down
    # do nothing
  end
  
  private
  
  def self.update(location)
    puts location.name
    raw_data = Tide.about(location.name)
    
    loc = {}
    
    # figure out columns in data
    a = raw_data[0].reverse.chop.chop.chop.chop.reverse.strip
    i = raw_data[0].index(a)

    # create a hash of all the input lines
    hash = Hash.new
    raw_data.each do |line|
      key = line[0..i-1].rstrip
      value = line[i..line.length - 1].rstrip
      hash[key] = value
    end
    
    # Search the hash and assign values to attributes
    loc[:name] = hash["Name"]

# Coordinates already exist
#    unless hash["Coordinates"].nil?
#      coordinates = hash["Coordinates"].split(",")
#      re = /(\d+).(\d+)/
#      md = re.match(coordinates[0])
#      if coordinates[0] =~ /S/
#        loc[:lat] = (-1.0 * md[0].to_f).to_s
#      else
#        loc[:lat] = (md[0].to_f).to_s
#      end
#      md = re.match(coordinates[1])
#      if coordinates[1] =~ /W/
#        loc[:lng] = (-1.0 * md[0].to_f).to_s
#      else
#        loc[:lng] = (md[0].to_f).to_s
#      end
#    end

    loc[:country] = hash["Country"]

    unless hash["Time zone"].nil?
      tz = hash["Time zone"]
      if tz.include?(":")
        loc[:time_zone] = tz.reverse.chop.reverse
      else
        loc[:time_zone] = tz
      end
    end

    loc[:restriction] = hash["Restriction"]

# loc_type already exists
#    type = hash["Type"]
#    unless type.nil?
#      if type =~ /Reference station, tide/
#        loc[:loc_type] = "REF"
#      else
#        loc[:loc_type] = "SUB"
#      end
#    end        

    loc[:reference] = hash["Reference"]
    
    Location.update(location.id, loc)
  end

end
