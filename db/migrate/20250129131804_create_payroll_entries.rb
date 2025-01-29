class CreatePayrollEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :payroll_entries do |t|
      t.references :payroll, null: false, foreign_key: true
      t.references :recordable, polymorphic: true, null: false  # IMPORTANTE

      t.timestamps
    end
  end
end
