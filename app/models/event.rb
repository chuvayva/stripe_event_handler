class Event < ApplicationRecord
  enumerize :state, in: %i[pending processing done error], default: :pending, predicates: true

  validates :stripe_id, presence: true, uniqueness: true
  validates :stripe_type, presence: true
end
