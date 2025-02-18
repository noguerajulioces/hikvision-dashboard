class AddProcessedToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :processed, :boolean, default: false
  end
end
