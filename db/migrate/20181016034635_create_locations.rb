class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|

      t.st_point :geometry, geographic: true, null: false
      t.index :geometry, using: :gist

      t.text :name, null: false
      t.text :description, null: false, default: ""
      t.text :image_url, null: false
      t.integer :reward, null: false

      t.timestamps
    end
  end
end
