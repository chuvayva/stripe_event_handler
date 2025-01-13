module WebhookService
  WEBHOOK_SECRET = Rails.application.credentials.dig(:stripe, :webhook_secret)
  MAX_EVENT_AGE = 300 # seconds

  class << self
    def event_received(payload, signature)
      stripe_event = Stripe::Webhook.construct_event(
        payload, signature, WEBHOOK_SECRET,
        tolerance: MAX_EVENT_AGE
      )
      Rails.logger.info "Stripe event received: #{stripe_event["type"]} #{stripe_event.id}"

      return if skip_processing?(stripe_event)

      EventHandlerJob.perform_later(
        stripe_id: stripe_event.id,
        stripe_type: stripe_event.type,
      )
    rescue JSON::ParserError
      Rails.logger.error "Stripe service. Invalid payload"
      nil
    rescue Stripe::SignatureVerificationError
      Rails.logger.error "Stripe service. Invalid signature"
      nil
    end

    private

    def skip_processing?(stripe_event)
      if Event.where(stripe_id: stripe_event.id).exists?
        Rails.logger.warn "Stripe event already exists: #{stripe_event.id}"
        return true
      end

      if EventLogic::HANDLERS.keys.exclude?(stripe_event.type)
        Rails.logger.warn "Stripe event type is not supported: #{stripe_event.type}"
        return true
      end

      false
    end
  end
end
