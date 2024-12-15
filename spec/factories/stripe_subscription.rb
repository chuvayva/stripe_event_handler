FactoryBot.define do
  factory :stripe_subscription, class: Stripe::Subscription do
    initialize_with do
      Stripe::Subscription.construct_from(
        {
          "id": "sub_1QWM97C1ckIJ9Ppdy4uCBRNd",
          "object": "subscription",
          "latest_invoice": "in_1QWM97C1ckIJ9Ppd0By9suFN"
        }
      )
    end
  end
end
