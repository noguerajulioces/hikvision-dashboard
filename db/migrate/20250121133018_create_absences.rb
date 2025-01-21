class CreateAbsences < ActiveRecord::Migration[8.0]
  def change
    create_table :absences do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :absence_type
      t.string :reason

      t.timestamps
    end
  end
end
