FactoryBot.define do
  factory :stripe_event_data, class: Hash do
    transient do
      id { "evt_#{SecureRandom.hex}" }
      subscription_id { "sub_#{SecureRandom.hex}" }
    end

    trait "customer.subscription.created" do
      initialize_with do
        {
          "id": id,
          "object": "event",
          "data": {
            "object": {
              "id": "sub_1QO2cbC1ckIJ9PpdgSRiB6QI",
              "object": "subscription"
            }
          },
          "type": "customer.subscription.created"
        }
      end
    end

    trait "invoice.payment_succeeded" do
      initialize_with do
        {
          "id": id,
          "object": "event",
          "data": {
            "object": {
              "id": "in_1QOHUKC1ckIJ9PpdisNoBYA2",
              "object": "invoice",
              "subscription": subscription_id
            }
          },
          "type": "invoice.payment_succeeded"
        }
      end
    end

    trait 'customer.subscription.deleted' do
      initialize_with do
        {
          "id": id,
          "object": "event",
          "data": {
            "object": {
              "id": subscription_id,
              "object": "subscription"
            }
          },
          "type": "customer.subscription.deleted"
        }
      end
    end
  end
end
