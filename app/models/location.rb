class Location < ActiveRecord::Base
  
  composed_of :tz, :class_name => 'TZInfo::Timezone', 
              :mapping => %w(time_zone time_zone)

  def get_info()
    Tide.about(self.name)
  end
  
  def get_chart(year, month, day)
    Chart.by_location(self, year, month, day)
  end
  
  def get_graph(year, month, day)
    Graph.by_location(self, year, month, day)
  end
  
end


