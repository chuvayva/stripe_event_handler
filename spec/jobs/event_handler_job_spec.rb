require 'rails_helper'

RSpec.describe EventHandlerJob, type: :job do
  subject(:run_job) { EventHandlerJob.perform_now(event) }
  let(:event) { create :event, 'customer.subscription.created' }

  it 'updates event state and json' do
    expect { run_job }
      .to change(event, :state).to('done')
      .and change(event, :json).to(nil)
  end

  context "when event is 'subscription created'" do
    let(:event) { create :event, 'customer.subscription.created' }

    it 'creates Subscription' do
      expect { run_job }.to change(Subscription, :count).by(1)
      expect(Subscription.last).to have_attributes(
        state: 'unpaid',
        stripe_id: be,
        events: [ event ]
      )
    end
  end

  context "when event is 'invoice paid'" do
    let(:event) { create :event, 'invoice.payment_succeeded', subscription_id: }

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
        run_job

        expect(subscription.reload).to be_paid
        expect(subscription.events).to include(event)
      end
    end

    context 'when Subscription does not exist in database' do
      let(:subscription_id) { "sub_1QOHUKC1ckIJ9PpdfbEdGIqH" }

      it 'creates paid Subscription' do
        expect { run_job }.to change(Subscription, :count).by(1)
        expect(Subscription.last).to have_attributes(
          state: 'paid',
          stripe_id: subscription_id,
          events: [ event ]
        )
      end
    end
  end

  context "when event is 'subscription deleted'" do
    let!(:event) { create :event, 'customer.subscription.deleted', subscription_id: }
    let(:subscription_id) { "sub_1QOHUKC1ckIJ9PpdfbEdGIqH" }

    context 'when Subscription exists in database' do
      let!(:subscription) { create(:subscription, :paid, stripe_id: subscription_id) }

      it 'updates Subscription' do
        run_job

        expect(subscription.reload).to be_canceled
        expect(subscription.events).to include(event)
      end
    end

    context 'when Subscription does not exist in database' do
      it 'creates paid Subscription' do
        expect { run_job }.to change(Subscription, :count).by(1)
        expect(Subscription.last).to have_attributes(
          state: 'unpaid',
          stripe_id: subscription_id,
          events: [ event ]
        )
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
        json: be,
      )
    end
  end
end
