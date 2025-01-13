module EventLogic
  HANDLERS = {
    "customer.subscription.created" => Events::CustomerSubscriptionCreated,
    "customer.subscription.deleted" => Events::CustomerSubscriptionDeleted,
    "invoice.payment_succeeded" => Events::InvoicePaymentSucceeded
  }

  class << self
    def process_event(stripe_id:, stripe_type: nil)
      event = Event.where(stripe_id:).first_or_create(stripe_type:)
      error = nil

      ActiveRecord::Base.transaction do
        event = Event.lock("FOR UPDATE SKIP LOCKED").find(event.id)

        return if event.nil? || event.done?

        event.update(state: :processing)
        Rails.logger.info "Event processing started: #{event.stripe_type} #{event.stripe_id}"

        begin
          stripe_event = Stripe::Event.retrieve(event.stripe_id)
          klass = HANDLERS[event.stripe_type]
          klass.call(event, stripe_event)

          event.update(state: :done)

          Rails.logger.info "Event processed: #{event.stripe_type} #{event.stripe_id}"
        rescue => e
          event.update(state: :error)
          Rails.logger.error "Event processing failed: #{event.stripe_type} #{event.stripe_id}. Error: #{e.message}"

          # Don't re-raise the error here
          # because we want to ensure a successfull transaction to save state: :error
          error = e
        end
      end

      raise error if error
    end
  end
end
