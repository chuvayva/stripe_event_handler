class SubscriptionLogic
  def self.sync_status(subscription)
    stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)
    latest_invoice = Stripe::Invoice.retrieve(stripe_subscription.latest_invoice)

    subscription.state = latest_invoice.status == "paid" ? :paid : :unpaid

    subscription
  end
end
