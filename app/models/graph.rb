include TZInfo
include Tide

# An <tt>ActionWebService::Struct</tt> representation of a graph.
#
# Fields:
# * <tt>lbound</tt> -- The lower bounds of the graph.
# * <tt>ubound</tt> -- The upper bounds of the graph.
# * <tt>points</tt> -- The points on the graph.
# * <tt>points</tt> -- The moon phase.
# * <tt>points</tt> -- The fishing probability.
class Graph < ActionWebService::Struct
  
  member :lbound, :float
  member :ubound, :float
  member :points, [Point]
  member :sunrise, Time
  member :sunset, Time
  member :moonrise, Time
  member :moonset, Time
  member :moon_phase, :integer
  member :probability, :integer
  
  # Return the <tt>Graph</tt> of <tt>Point</tt> objects for the +year+, +month+, 
  # +day+ at the given +location+.
  def self.by_location(location, year, month, day)
    begin_time = Time.utc(year, month, day)
    end_time = begin_time + (24 * 60 * 60)
    tz = Timezone.get(location.time_zone)
    b = tz.local_to_utc(begin_time)
    e = tz.local_to_utc(end_time)
    
    points = []
    
    Tide.raw_csv(location.name, b, e).each do |line|
      fields = line.split(",")
      x = fields[1].to_f
      y = fields[2].to_f
      point = Point.new(:x => x, :y => y)
      points << point
    end
    
    # get bounds
    lbound = nil; ubound = nil
    Tide.stats(location.name, b, e).each do |line|
      fields = line.split
      if line =~ /Mathematical upper bound/
        fields.each do |field|
          if field =~ /(\d+)\.(\d+)/ 
            ubound = field.to_f
          end
        end
      end
      
      if line =~ /Mathematical lower bound/
        fields.each do |field|
          if field =~ /(\d+)\.(\d+)/ 
            lbound = field.to_f
          end
        end
      end
      
    end
    
    # TODO get probability
    probability = 0
    
    # get moon phase
    moon_phase = 0
    sunrise = nil; sunset = nil
    moonrise = nil; moonset = nil
    Tide.plain_csv(location.name, b, e).each do |line|
      fields = line.split(",")
      moon_phase = 1 if fields[4] =~ /New/
      moon_phase = 2 if fields[4] =~ /First/
      moon_phase = 3 if fields[4] =~ /Full/
      moon_phase = 4 if fields[4] =~ /Last/
      sunrise = parse_time(fields, tz) if fields[4] =~ /Sunrise/
      sunset = parse_time(fields, tz) if fields[4] =~ /Sunset/
      moonrise = parse_time(fields, tz) if fields[4] =~ /Moonrise/
      moonset = parse_time(fields, tz) if fields[4] =~ /Moonset/
    end
    
    return Graph.new(:ubound => ubound,
      :lbound => lbound,
      :points => points, 
      :sunrise => sunrise,
      :sunset => sunset,
      :moonrise => moonrise,
      :moonset => moonset,
      :moon_phase => moon_phase, 
      :probability => probability)
  end
  
  private
  
  def self.parse_time(fields, tz)
    time = Time.parse(fields[1] + " " + fields[2])
    tz.utc_to_local(time)
  end
  
end