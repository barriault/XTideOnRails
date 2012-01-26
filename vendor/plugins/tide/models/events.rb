require_gem 'tzinfo'
require 'tide'
include TZInfo
include Tide

# An <tt>ActionWebService::Struct</tt> representation of a set of tide events.
#
# Fields:
# * <tt>day</tt> -- The day of the event.
# * <tt>date</tt> -- The datetime of the events.
# * <tt>events</tt> -- An <tt>Array</tt> of <tt>Event</tt> objects.
class Events < ActionWebService::Struct
  member :day, :string
  member :date, :datetime
  member :events, [Event]
  
  # Return the <tt>Events</tt> for the given location +name+.
  def self.by_location(name, begin_time, end_time)
    location = Location.find_by_name(name)
   
    tz = Timezone.get(location.time_zone)
    b = tz.local_to_utc(begin_time)
    e = tz.local_to_utc(end_time)
    
    events = []
    
    Tide.plain_csv(name, b, e).each do |line|
      fields = line.split(",")
      time = Time.parse(fields[1] + " " + fields[2])
      event_time = tz.utc_to_local(time).strftime("%I:%M %p")
      event_type = fields[3]
      tide_height = fields[4]
      event = Event.new(:event_time => event_time, :event_type => event_type, :tide_height => tide_height)
      events << event
    end
    return Events.new(:day => tz.utc_to_local(b).strftime("%A, %B %d, %Y"), :date => tz.utc_to_local(b), :events => events)
  end
  
end