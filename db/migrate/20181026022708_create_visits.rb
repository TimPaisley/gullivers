class CreateVisits < ActiveRecord::Migration[5.2]
  def change
    create_table :visits do |t|

      t.timestamps

      t.belongs_to :user, null: false
      t.belongs_to :location, null: false
    end
  end
end
