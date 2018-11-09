# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_07_042852) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "adventures", force: :cascade do |t|
    t.text "name", null: false
    t.text "description", default: "", null: false
    t.text "badge_url", null: false
    t.integer "difficulty", null: false
    t.boolean "wheelchair_accessible", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.geography "geometry", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}, null: false
    t.text "name", null: false
    t.text "description", default: "", null: false
    t.text "image_url", null: false
    t.integer "reward", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geometry"], name: "index_locations_on_geometry", using: :gist
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "location_id", null: false
    t.index ["location_id"], name: "index_visits_on_location_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

end
