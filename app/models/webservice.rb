include TZInfo
include Tide

# An <tt>ActionWebService::Struct</tt> representation of a set of tide events.
#
# Fields:
# * <tt>day</tt> -- The day of the event.
# * <tt>date</tt> -- The datetime of the events.
# * <tt>events</tt> -- An <tt>Array</tt> of <tt>Event</tt> objects.
class Webservice < ActionWebService::Struct
  
  member :name, :string
  member :lat, :float
  member :lng, :float
  member :date, :string
  member :events, [Event]
  
  # Return the <tt>Chart</tt> of <tt>Event</tt> objects for the +year+, +month+, 
  # +day+ at the given +location+.
  def self.by_location(location, year, month, day)
    begin_time = Time.utc(year, month, day)
    end_time = begin_time + (24 * 60 * 60)
    tz = Timezone.get(location.time_zone)
    b = tz.local_to_utc(begin_time)
    e = tz.local_to_utc(end_time)
    
    events = []
    
    Tide.plain_csv(location.name, b, e).each do |line|
      fields = line.split(",")
      time = Time.parse(fields[1] + " " + fields[2])
      event_time = tz.utc_to_local(time).strftime("%I:%M %p")
      event_type = fields[3]
      tide_height = fields[4]
      event = Event.new(:event_time => event_time, :event_type => event_type, :tide_height => tide_height)
      events << event
    end
    return Webservice.new(:name => location.name,
      :lat => location.latitude,
      :lng => location.longitude,
      :date => tz.utc_to_local(b).strftime("%A, %B %d, %Y"), 
      :events => events)
  end
  
end