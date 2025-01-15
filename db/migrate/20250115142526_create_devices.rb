class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :ip_address
      t.string :model

      t.timestamps
    end
  end
end
