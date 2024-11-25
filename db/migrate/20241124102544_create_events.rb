class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :stripe_id, null: false, index: { unique: true }
      t.string :stripe_type, null: false
      t.string :state, default: :pending, null: false

      t.timestamps
    end
  end
end
