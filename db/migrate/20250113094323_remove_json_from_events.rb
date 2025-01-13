class RemoveJsonFromEvents < ActiveRecord::Migration[8.0]
  def change
    remove_column :events, :json, :jsonb
  end
end
