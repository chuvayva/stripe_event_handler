FactoryBot.define do
  factory :stripe_invoice, class: Stripe::Invoice do
    transient do
      status { "paid" }
    end

    initialize_with do
      Stripe::Invoice.construct_from(
        {
          "id": "in_1QWM97C1ckIJ9Ppd0By9suFN",
          "object": "invoice",
          "status": status
        }
      )
    end
  end
end
