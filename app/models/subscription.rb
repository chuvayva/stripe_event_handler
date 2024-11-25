class Subscription < ApplicationRecord
  include SubscriptionStateMachine

  has_and_belongs_to_many :events

  validates :stripe_id, presence: true, uniqueness: true
end
