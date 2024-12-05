module Events
  module InvoicePaymentSucceeded
    def self.call(event, stripe_event)
      stripe_subscription_id = stripe_event.data.object.subscription

      if stripe_subscription_id.nil?
        Rails.logger.info "Invoice event #{event.stripe_id} is not connected to a subscription"
        return
      end

      subscription = Subscription.find_by_stripe_id(stripe_subscription_id)

      case subscription
      in nil
        Subscription.create(stripe_id: stripe_subscription_id, events: [ event ], state: :paid)
        Rails.logger.info "Subscription #{stripe_subscription_id} not found. Create it"
      in Subscription
        subscription.pay_invoice
        subscription.events << event
        subscription.save
      end
    end
  end
end
