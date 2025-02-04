# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_29_152136) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "absences", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.integer "absence_type"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_absences_on_employee_id"
  end

  create_table "attendance_records", force: :cascade do |t|
    t.integer "employee_id"
    t.datetime "entry_time"
    t.datetime "exit_time"
    t.integer "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "processed"
    t.bigint "schedule_id"
    t.index ["schedule_id"], name: "index_attendance_records_on_schedule_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "name"
    t.string "ip_address"
    t.string "model"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "hire_date"
    t.date "termination_date"
    t.string "phone"
    t.string "email"
    t.string "document_number"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incidents", force: :cascade do |t|
    t.integer "employee_id"
    t.date "date"
    t.string "issue"
    t.boolean "resolved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "overtime_records", force: :cascade do |t|
    t.integer "employee_id"
    t.date "date"
    t.decimal "hours_worked"
    t.decimal "compensation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payroll_entries", force: :cascade do |t|
    t.bigint "payroll_id", null: false
    t.string "recordable_type", null: false
    t.bigint "recordable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payroll_id"], name: "index_payroll_entries_on_payroll_id"
    t.index ["recordable_type", "recordable_id"], name: "index_payroll_entries_on_recordable"
  end

  create_table "payrolls", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.decimal "total_hours_worked", precision: 15, scale: 2
    t.decimal "total_overtime_hours", precision: 15, scale: 2
    t.integer "total_incidents"
    t.integer "total_payment"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_payrolls_on_employee_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "schedules", force: :cascade do |t|
    t.bigint "group_id"
    t.datetime "expected_entry_time"
    t.datetime "expected_exit_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date", null: false
    t.index ["group_id", "date"], name: "index_schedules_on_group_id_and_date", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone"
    t.boolean "active"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "absences", "employees"
  add_foreign_key "attendance_records", "schedules"
  add_foreign_key "payroll_entries", "payrolls"
  add_foreign_key "payrolls", "employees"
end
