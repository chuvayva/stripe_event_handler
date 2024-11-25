class AddJsonToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :json, :jsonb
  end
end
