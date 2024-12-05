module Events
  module CustomerSubscriptionDeleted
    def self.call(event, stripe_event)
      stripe_subscription_id = stripe_event.data.object.id
      subscription = Subscription.find_by_stripe_id(stripe_subscription_id)

      case subscription
      in nil
        Subscription.create(stripe_id: stripe_subscription_id, events: [ event ], state: :unpaid)
        Rails.logger.info "Subscription #{stripe_subscription_id} not found. Create it"
      in Subscription
        subscription.cancel_subscription
        subscription.events << event
        subscription.save
      end
    end
  end
end
