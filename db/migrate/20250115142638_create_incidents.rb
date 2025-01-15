class CreateIncidents < ActiveRecord::Migration[8.0]
  def change
    create_table :incidents do |t|
      t.integer :employee_id
      t.date :date
      t.string :issue
      t.boolean :resolved

      t.timestamps
    end
  end
end
