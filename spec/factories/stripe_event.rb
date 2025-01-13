FactoryBot.define do
  factory :stripe_event, class: Stripe::Event do
    transient do
      data { {} }
    end

    initialize_with do
      Stripe::Event.construct_from(data)
    end
  end
end
