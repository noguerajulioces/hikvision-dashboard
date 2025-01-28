class CreatePayrollReports < ActiveRecord::Migration[8.0]
  def change
    create_table :payrolls do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :total_hours_worked, precision: 15, scale: 2
      t.decimal :total_overtime_hours, precision: 15, scale: 2
      t.integer :total_incidents
      t.integer :total_payment
      t.text :comments

      t.timestamps
    end
  end
end
