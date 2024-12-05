class RemoveEventsSubscriptions < ActiveRecord::Migration[7.2]
  def change
    drop_join_table :events, :subscriptions

    add_reference :events, :subscription, foreign_key: true
  end
end
