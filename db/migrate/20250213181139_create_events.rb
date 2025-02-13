class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :s_name
      t.string :s_job_no
      t.string :s_card
      t.date :date
      t.time :time
      t.string :in_out
      t.integer :read_id
      t.integer :event_main_code
      t.integer :event_sub_code
      t.string :attendance_status
      t.string :wear_mask
      t.integer :serial_no
      t.references :device, foreign_key: true
      t.references :employee, foreign_key: true, null: true

      t.timestamps
    end
  end
end
