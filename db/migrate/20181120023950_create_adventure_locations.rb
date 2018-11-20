class CreateAdventureLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :adventure_locations do |t|

      t.timestamps

      t.belongs_to :adventure, null: false
      t.belongs_to :location, null: false
    end
  end
end
