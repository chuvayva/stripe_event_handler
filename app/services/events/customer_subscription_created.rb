module Events
  module CustomerSubscriptionCreated
    def self.call(event, stripe_event)
      stripe_subscription_id = stripe_event.data.object.id
      Subscription.create(stripe_id: stripe_subscription_id, events: [ event ])
    end
  end
end
