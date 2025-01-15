class AddPhoneAndEmailToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :phone, :string
    add_column :employees, :email, :string
  end
end
