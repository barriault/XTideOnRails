# An <tt>ActionWebService::Struct</tt> representation of a tide event.
#
# Fields:
# * <tt>event_time</tt> -- The time of the event in local time.
# * <tt>event_type</tt> -- The type of event.
# * <tt>tide_height</tt> -- The height for High Tide and Low Tide events.
class Event < ActionWebService::Struct
  member :event_time,  :string
  member :event_type,  :string
  member :tide_height, :string
end