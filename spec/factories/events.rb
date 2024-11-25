FactoryBot.define do
  factory :event do
    stripe_id { |n| "evt_#{SecureRandom.hex}" }
    stripe_type { "customer.subscription.created" }
    state { :pending }

    trait "customer.subscription.created" do
      stripe_type { "customer.subscription.created" }
      state { :done }
    end

    trait "invoice.payment_succeeded" do
      stripe_type { "invoice.payment_succeeded" }
      state { :done }
    end

    trait "customer.subscription.deleted" do
      stripe_type { "customer.subscription.deleted" }
      state { :done }
    end
  end
end
