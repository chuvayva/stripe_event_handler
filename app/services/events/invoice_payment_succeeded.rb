module Events
  module InvoicePaymentSucceeded
    def self.call(event, stripe_event)
      stripe_subscription_id = stripe_event.data.object.subscription
      subscription = Subscription.find_by_stripe_id(stripe_subscription_id)
      subscription.pay_invoice
      subscription.events << event
      subscription.save
    end
  end
end
