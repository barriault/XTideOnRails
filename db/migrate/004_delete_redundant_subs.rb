class DeleteRedundantSubs < ActiveRecord::Migration
  def self.up
    Location.find(:all, :conditions => ["loc_type = ?", "REF"]).each do |loc|
      Location.delete_all ["latitude = ? AND longitude = ? AND loc_type = ?", 
        loc.latitude, loc.longitude, "SUB"]
    end
  end

  def self.down
    # do nothing
  end
end
