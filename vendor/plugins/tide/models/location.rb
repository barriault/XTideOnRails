require 'tide'
include Tide

class LocationNotFoundException < StandardError #:nodoc:
end

# An <tt>ActionWebService::Struct</tt> representation of a location.
#
# Fields:
# * <tt>name</tt> -- The name of the location.
# * <tt>lat</tt> -- The location's latitude coordinate.
# * <tt>lng</tt> -- The location's longitude coordinate.
# * <tt>country</tt> -- The location's country.
# * <tt>time_zone</tt> -- The location's time zone.
# * <tt>restriction</tt> -- The location's restriction.
# * <tt>loc_type</tt> -- The location type.
# * <tt>reference</tt> -- The reference location if <tt>loc_type</tt> = SUB.
class Location < ActionWebService::Struct
  member :name,  :string
  member :lat,  :string
  member :lng, :string
  member :country, :string
  member :time_zone, :string
  member :restriction, :string
  member :loc_type, :string
  member :reference, :string

  # Returns an <tt>Array</tt> of <tt>Location</tt> objects with only the 
  # <tt>name</tt>, <tt>lat</tt>, <tt>lng</tt>, and <tt>loc_type</tt> 
  # attributes populated.
  def self.list_all
    array = []
    raw_data = Tide.list
    raw_data[2..raw_data.length - 1].each do |line|
      name = line[0..50]
      type = line[52..54].upcase
      coords = Location.get_coordinates(line)
      array << Location.new({ :name => name.rstrip, :loc_type => type, :lat => coords[0], :lng => coords[1] })
    end
    return array
  end

  # Returns the <tt>Location</tt> for +name+.
  def self.find_by_name(name)
    raw_data = Tide.about(name)
    loc = Location.new
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
    loc.name = hash["Name"]

    unless hash["Coordinates"].nil?
      coordinates = hash["Coordinates"].split(",")
      re = /(\d+).(\d+)/
      md = re.match(coordinates[0])
      if coordinates[0] =~ /S/
        loc.lat = (-1.0 * md[0].to_f).to_s
      else
        loc.lat = (md[0].to_f).to_s
      end
      md = re.match(coordinates[1])
      if coordinates[1] =~ /W/
        loc.lng = (-1.0 * md[0].to_f).to_s
      else
        loc.lng = (md[0].to_f).to_s
      end
    end

    loc.country = hash["Country"]

    unless hash["Time zone"].nil?
      tz = hash["Time zone"]
      if tz.include?(":")
        loc.time_zone = tz.reverse.chop.reverse
      else
        loc.time_zone = tz
      end
    end

    loc.restriction = hash["Restriction"]

    type = hash["Type"]
    unless type.nil?
      if type =~ /Reference station, tide/
        loc.loc_type = "REF"
      else
        loc.loc_type = "SUB"
      end
    end        

    loc.reference = hash["Reference"]

    return loc
  rescue TideFatalException
    STDERR.puts "location #{name} not found"
    raise LocationNotFoundException.new("location #{name} not found")
  end
  
  # Returns the <tt>Location</tt> for latitude = +lat+ and longitude = +lng+.
  def self.find_by_coordinates(coords)
    if coords.kind_of?(Array)
      Location.list_all.each do |loc|
        if loc.lat == coords[0] && loc.lng == coords[1]
          return Location.find_by_name(loc.name)
        end
      end
    else
      raise "Invalid coordinates."
    end
    raise LocationNotFoundException.new("Location not found for coordinates lat = #{coords[0]}, lng = #{coords[1]}.")
  end

  private

  def self.get_coordinates(line)
    coords = []
    array = line[56..line.length].chomp.split(",")
    re = /(\d+).(\d+)/
    md = re.match(array[0])
    if array[0] =~ /S/
      coords[0] = (-1.0 * md[0].to_f).to_s
    else
      coords[0] = (md[0].to_f).to_s
    end
    md = re.match(array[1])
    if array[1] =~ /W/
      coords[1] = (-1.0 * md[0].to_f).to_s
    else
      coords[1] = (md[0].to_f).to_s
    end
    return coords
  end
end
