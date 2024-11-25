require 'rails_helper'

describe "POST /webhook", type: :request do
  subject(:post_webhook_path) { post webhook_path, params: payload, as: :json }

  context 'when webhook signature is valid' do
    before do
      allow(Stripe::Webhook).to receive(:construct_event) do |payload|
        Stripe::Event.construct_from(JSON.parse(payload))
      end
    end

    context "when event is 'subscription created'" do
      let(:payload) { build(:stripe_event_data, "customer.subscription.created") }

      it 'creates Event' do
        expect { post_webhook_path }.to change(Event, :count).by(1)
        expect(Event.last).to have_attributes(
          state: 'done',
          stripe_id: be,
          stripe_type: be,
        )
      end

      it 'creates Subscription' do
        expect { post_webhook_path }.to change(Subscription, :count).by(1)
        expect(Subscription.last).to have_attributes(
          state: 'unpaid',
          stripe_id: be,
        )
      end

      it "responds 200" do
        post_webhook_path

        expect(response).to have_http_status(200)
      end

      context 'when event handling raised an error' do
        before do
          allow(Events::CustomerSubscriptionCreated).to receive(:call).and_raise(RuntimeError)
        end

        it 'creates Event in error state' do
          expect { post_webhook_path }.to raise_error(RuntimeError)
          expect(Event.last).to have_attributes(
            state: 'error',
            stripe_id: be,
            stripe_type: be,
          )
        end
      end

      context 'when event exists' do
        let!(:event) { create :event, stripe_id: payload[:id] }

        it 'does not create Event' do
          expect { post_webhook_path }.not_to change(Event, :count)
        end
      end
    end

    context "when event is 'invoice paid'" do
      let(:payload) { build(:stripe_event_data, "invoice.payment_succeeded", subscription_id:) }

      let(:subscription_id) { "sub_1QOHUKC1ckIJ9PpdfbEdGIqH" }
      let!(:subscription) { create(:subscription, :unpaid, stripe_id: subscription_id) }

      it 'creates Event' do
        expect { post_webhook_path }.to change(Event, :count).by(1)
        expect(Event.last).to have_attributes(
          state: 'done',
          stripe_id: be,
          stripe_type: be,
        )
      end

      it 'update Subscription' do
        post_webhook_path

        expect(subscription.reload).to be_paid
      end

      it "responds 200" do
        post_webhook_path

        expect(response).to have_http_status(200)
      end
    end

    context "when event is 'subscription deleted'" do
      let(:payload) { build(:stripe_event_data, "customer.subscription.deleted", subscription_id:) }

      let(:subscription_id) { "sub_1QOHUKC1ckIJ9PpdfbEdGIqH" }
      let!(:subscription) { create(:subscription, :paid, stripe_id: subscription_id) }

      it 'creates Event' do
        expect { post_webhook_path }.to change(Event, :count).by(1)
        expect(Event.last).to have_attributes(
          state: 'done',
          stripe_id: be,
          stripe_type: be,
        )
      end

      it 'update Subscription' do
        post_webhook_path

        expect(subscription.reload).to be_canceled
      end

      it "responds 200" do
        post_webhook_path

        expect(response).to have_http_status(200)
      end
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
