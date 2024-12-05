class Subscription < ApplicationRecord
  include SubscriptionStateMachine

  has_many :events

  validates :stripe_id, presence: true, uniqueness: true
end
