class Subscription < ApplicationRecord
  extend Enumerize
  enumerize :state, in: %i[unpaid paid canceled], default: :unpaid, predicates: true, scope: :shallow

  has_many :events

  validates :stripe_id, presence: true, uniqueness: true
end
