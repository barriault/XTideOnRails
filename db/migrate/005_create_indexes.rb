class CreateIndexes < ActiveRecord::Migration
  def self.up
    add_index :locations, :name
    add_index :locations, :latitude
    add_index :locations, :longitude
  end

  def self.down
    remove_index :locations, :name
    remove_index :locations, :latitude
    remove_index :locations, :longitude
  end
end
