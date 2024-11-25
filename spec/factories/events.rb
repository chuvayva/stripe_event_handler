FactoryBot.define do
  factory :event do
    stripe_id { |n| "evt_#{SecureRandom.hex}" }
    stripe_type { "customer.subscription.created" }
    state { :pending }

    trait "customer.subscription.created" do
      stripe_type { "customer.subscription.created" }
      json { build(:stripe_event_data, 'customer.subscription.created').to_json }
    end

    trait "invoice.payment_succeeded" do
      transient do
        subscription_id { "sub_#{SecureRandom.hex}" }
      end

      stripe_type { "invoice.payment_succeeded" }
      json { build(:stripe_event_data, 'invoice.payment_succeeded', subscription_id:).to_json }
    end

    trait "customer.subscription.deleted" do
      transient do
        subscription_id { "sub_#{SecureRandom.hex}" }
      end

      stripe_type { "customer.subscription.deleted" }
      json { build(:stripe_event_data, 'customer.subscription.deleted', subscription_id:).to_json }
    end
  end
end
