class StripeController < ApplicationController
  def webhook
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]

    WebhookService.event_received(payload, signature)

    head :ok
  end
end
