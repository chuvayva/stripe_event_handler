module Events
  module CustomerSubscriptionDeleted
    def self.call(event, stripe_event)
      stripe_subscription_id = stripe_event.data.object.id

      ActiveRecord::Base.transaction do
        subscription = Subscription.where(stripe_id: stripe_subscription_id).first_or_initialize
        subscription.state = :canceled
        subscription.save
        subscription.events << event
      end
    end
  end
end
