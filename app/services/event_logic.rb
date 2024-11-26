module EventLogic
  class << self
    def process_event(event)
      return unless event.pending? || event.error?

      event.update(state: :processing)
      Rails.logger.info "Event processing started: #{event.stripe_type} #{event.stripe_id}"

      event_data = JSON.parse(event.json)
      stripe_event = Stripe::Event.construct_from(event_data)

      klass = event.stripe_type.gsub(".", "_").classify
      "Events::#{klass}".constantize.call(event, stripe_event)

      event.update(state: :done, json: nil)

      Rails.logger.info "Event processed: #{event.stripe_type} #{event.stripe_id}"
    rescue => e
      event.update(state: :error)
      Rails.logger.error "Event processing failed: #{event.stripe_type} #{event.stripe_id}. Error: #{e.message}"

      raise
    end
  end
end
