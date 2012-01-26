class DeleteNonPublicDomainLocations < ActiveRecord::Migration
  def self.up
    Location.delete_all "restriction <> 'Public domain'"
  end

  def self.down
    # do nothing
  end
end
