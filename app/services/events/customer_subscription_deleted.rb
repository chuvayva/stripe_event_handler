module Events
  module CustomerSubscriptionDeleted
    def self.call(event, stripe_event)
      stripe_subscription_id = stripe_event.data.object.id

      subscription = Subscription.where(stripe_id: stripe_subscription_id).first_or_initialize
      subscription = SubscriptionLogic.sync_status(subscription)
      subscription.save

      ActiveRecord::Base.transaction do
        subscription.cancel_subscription!
        subscription.events << event
      end
    end
  end
end
