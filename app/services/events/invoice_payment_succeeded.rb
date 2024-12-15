module Events
  module InvoicePaymentSucceeded
    def self.call(event, stripe_event)
      stripe_subscription_id = stripe_event.data.object.subscription

      if stripe_subscription_id.nil?
        Rails.logger.info "Invoice event #{event.stripe_id} is not connected to a subscription"
        return
      end

      subscription = Subscription.where(stripe_id: stripe_subscription_id).first_or_initialize

      ActiveRecord::Base.transaction do
        subscription.pay_invoice!
        subscription.events << event
      end
    end
  end
end
