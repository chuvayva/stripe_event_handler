require 'rails_helper'

describe "POST /webhook", type: :request do
  subject(:post_webhook_path) { post webhook_path, params: payload, as: :json }
  let(:payload) { build(:stripe_event_data, "customer.subscription.created") }

  context 'when signature is valid' do
    before do
      # bypass signature validation
      allow(Stripe::Webhook).to receive(:construct_event) do |payload|
        Stripe::Event.construct_from(JSON.parse(payload))
      end
    end

    it 'schedule a background job' do
      expect {
        post_webhook_path
      }.to have_enqueued_job(EventHandlerJob)
    end

    it "responds 200" do
      post_webhook_path

      expect(response).to have_http_status(200)
    end
  end

  context 'when signature is invalid' do
    let(:payload) { {} }

    it 'does not create Event' do
      expect { post_webhook_path }.not_to change(Event, :count)
    end

    it 'does not create Subscription' do
      expect { post_webhook_path }.not_to change(Subscription, :count)
    end

    it "responds 200" do
      post_webhook_path

      expect(response).to have_http_status(200)
    end
  end
end
