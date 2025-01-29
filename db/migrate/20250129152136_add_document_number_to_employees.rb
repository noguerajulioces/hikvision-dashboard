class AddDocumentNumberToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :document_number, :string
  end
end
