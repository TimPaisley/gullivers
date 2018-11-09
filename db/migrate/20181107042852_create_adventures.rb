class CreateAdventures < ActiveRecord::Migration[5.2]
  def change
    create_table :adventures do |t|

        t.text :name, null: false
        t.text :description, null: false, default: ""
        t.text :badge_url, null: false
        t.integer :difficulty, null: false
        t.boolean :wheelchair_accessible, null: false

        t.timestamps
    end
  end
end
