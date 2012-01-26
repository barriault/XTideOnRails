class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.column :name,        :string
      t.column :latitude,    :decimal, :precision => 15, :scale => 10
      t.column :longitude,   :decimal, :precision => 15, :scale => 10
      t.column :country,     :string
      t.column :time_zone,   :string
      t.column :restriction, :string
      t.column :loc_type,    :string
      t.column :reference,   :string
    end
    CreateLocations.create_all
  end

  def self.down
    drop_table :locations
  end
  
  private
  
  def self.create_all
    raw_data = Tide.list
    raw_data[2..raw_data.length - 1].each do |line|
      name = line[0..50]
      type = line[52..54].upcase
      coords = CreateLocations.get_coordinates(line)
      loc = Location.create({ :name => name.rstrip, :loc_type => type, :latitude => coords[0], :longitude => coords[1] })
      puts loc.name
    end
  end

  def self.get_coordinates(line)
  coords = []
  array = line[56..line.length].chomp.split(",")
  re = /(\d+).(\d+)/
  md = re.match(array[0])
  if array[0] =~ /S/
    coords[0] = (-1.0 * md[0].to_f)
  else
    coords[0] = (md[0].to_f)
  end
  md = re.match(array[1])
  if array[1] =~ /W/
    coords[1] = (-1.0 * md[0].to_f)
  else
    coords[1] = (md[0].to_f)
  end
  return coords
end

end
