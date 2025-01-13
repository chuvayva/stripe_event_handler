require 'rails_helper'

RSpec.describe EventHandlerJob, type: :job do
  subject(:run_job) { EventHandlerJob.perform_now(stripe_id: stripe_event.id, stripe_type: stripe_event.type) }

  let(:event_data) { build(:stripe_event_data, 'customer.subscription.created') }
  let(:stripe_event) { build(:stripe_event, data: event_data) }

  before do
    allow(Stripe::Event).to receive(:retrieve).and_return(stripe_event)
  end

  it 'creates Event' do
    expect { run_job }.to change(Event, :count).by(1)
    expect(Event.last).to have_attributes(
      state: 'done',
      stripe_id: be,
      stripe_type: be,
    )
  end

  context "when event is 'subscription created'" do
    let(:event_data) { build(:stripe_event_data, 'customer.subscription.created') }

    it 'creates Subscription' do
      expect { run_job }.to change(Subscription, :count).by(1)
      expect(Subscription.last).to have_attributes(
        state: 'unpaid',
        stripe_id: be,
        events: be,
      )
    end
  end

  context "when event is 'invoice paid'" do
    let(:event_data) { build(:stripe_event_data, 'invoice.payment_succeeded', subscription_id:) }

    context 'when invoice event is not connected to a Subscription' do
      let(:subscription_id) { nil }

      it 'does not update any subscription' do
        expect { run_job }.not_to change(Subscription.paid, :count)
      end
    end

    context 'when Subscription exists in database' do
      let(:subscription_id) { "sub_1QOHUKC1ckIJ9PpdfbEdGIqH" }
      let!(:subscription) { create(:subscription, :unpaid, stripe_id: subscription_id) }

      it 'updates Subscription' do
        expect { run_job }.to change(subscription.events, :count).by(1)

        expect(subscription.reload).to be_paid
      end
    end

    context 'when Subscription does not exist in database' do
      let(:subscription_id) { "sub_1QOHUKC1ckIJ9PpdfbEdGIqH" }

      it 'creates paid Subscription' do
        expect { run_job }.to change(Subscription, :count).by(1)
        expect(Subscription.last).to have_attributes(
          state: 'paid',
          stripe_id: subscription_id,
          events: be,
        )
      end
    end
  end

  context "when event is 'subscription deleted'" do
    let!(:event_data) { build(:stripe_event_data, 'customer.subscription.deleted', subscription_id:) }
    let(:subscription_id) { "sub_1QOHUKC1ckIJ9PpdfbEdGIqH" }

    let(:stripe_invoice) { build(:stripe_invoice, status: invoice_status) }
    let(:stripe_subscription) { build(:stripe_subscription) }

    before do
      allow(Stripe::Subscription).to receive(:retrieve).and_return(stripe_subscription)
      allow(Stripe::Invoice).to receive(:retrieve)
        .with(stripe_subscription.latest_invoice)
        .and_return(stripe_invoice)
    end

    context "when NO local record, stripe invoice PAID" do
      let(:invoice_status) { 'paid' }

      it 'creates canceled Subscription' do
        expect { run_job }.to change(Subscription, :count).by(1)
        expect(Subscription.last).to have_attributes(
          state: 'canceled',
          stripe_id: subscription_id,
          events: be,
        )
      end
    end

    context "when NO local record, stripe invoice NOT PAID" do
      let(:invoice_status) { 'draft' }

      it 'raises InvalidTransition' do
        expect { run_job }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when local record is PAID, stripe invoice PAID" do
      let!(:subscription) { create(:subscription, :paid, stripe_id: subscription_id) }
      let(:invoice_status) { 'paid' }

      it 'updates Subscription' do
        expect { run_job }.to change(subscription.events, :count).by(1)

        expect(subscription.reload).to be_canceled
      end
    end

    context "when local record is PAID, stripe invoice NOT PAID" do
      let!(:subscription) { create(:subscription, :paid, stripe_id: subscription_id) }
      let(:invoice_status) { 'draft' }

      it 'raises InvalidTransition' do
        expect { run_job }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when local record is NOT PAID, stripe invoice PAID" do
      let!(:subscription) { create(:subscription, :unpaid, stripe_id: subscription_id) }
      let(:invoice_status) { 'paid' }

      it 'updates Subscription' do
        expect { run_job }.to change(subscription.events, :count).by(1)

        expect(subscription.reload).to be_canceled
      end
    end

    context "when local record is NOT PAID, stripe invoice NOT PAID" do
      let!(:subscription) { create(:subscription, :unpaid, stripe_id: subscription_id) }
      let(:invoice_status) { 'draft' }

      it 'raises InvalidTransition' do
        expect { run_job }.to raise_error(AASM::InvalidTransition)
      end
    end
  end

  context 'when event handling raised an error' do
    before do
      allow(Events::CustomerSubscriptionCreated).to receive(:call).and_raise(RuntimeError)
    end

    it 'creates Event in error state' do
      expect { run_job }.to raise_error(RuntimeError)
      expect(Event.last).to have_attributes(
        state: 'error',
      )
    end
  end
end
