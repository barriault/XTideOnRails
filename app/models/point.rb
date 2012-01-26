# An <tt>ActionWebService::Struct</tt> representation of a point on a graph.
#
# Fields:
# * <tt>x</tt> -- The x coordinate.
# * <tt>y</tt> -- The y coordinate.
class Point < ActionWebService::Struct
  member :x,  :float
  member :y,  :float
end