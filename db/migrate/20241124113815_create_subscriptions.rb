class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_id, null: false, index: { unique: true }
      t.string :state, default: :unpaid, null: false

      t.timestamps
    end

    create_join_table :events, :subscriptions
  end
end
