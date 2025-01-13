FactoryBot.define do
  factory :event do
    stripe_id { |n| "evt_#{SecureRandom.hex}" }
    stripe_type { "customer.subscription.created" }
    state { :pending }

    trait "customer.subscription.created" do
      stripe_type { "customer.subscription.created" }
    end

    trait "invoice.payment_succeeded" do
      transient do
        subscription_id { "sub_#{SecureRandom.hex}" }
      end

      stripe_type { "invoice.payment_succeeded" }
    end

    trait "customer.subscription.deleted" do
      transient do
        subscription_id { "sub_#{SecureRandom.hex}" }
      end

      stripe_type { "customer.subscription.deleted" }
    end
  end
end
