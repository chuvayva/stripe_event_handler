FactoryBot.define do
  factory :subscription do
    stripe_id { |n| "sub_#{SecureRandom.hex}" }
    state { :unpaid }

    trait :unpaid do
      state { :unpaid }

      after(:create) do |subscription|
        subscription.events << create(:event, "customer.subscription.created")
      end
    end

    trait :paid do
      state { :paid }

      after(:create) do |subscription|
        %w[customer.subscription.created invoice.payment_succeeded].each do |trait|
          subscription.events << create(:event, trait)
        end
      end
    end
  end
end
