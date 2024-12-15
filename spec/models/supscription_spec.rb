require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'State Machine Transitions' do
    let(:subscription) { Subscription.new }

    it 'tests all possible state transitions' do
      expect(subscription).to have_state(:unpaid)

      # Transitions for pay_invoice event
      expect(subscription).to transition_from(:unpaid).to(:paid).on_event(:pay_invoice)
      expect(subscription).to transition_from(:paid).to(:paid).on_event(:pay_invoice)
      expect(subscription).to transition_from(:canceled).to(:paid).on_event(:pay_invoice)

      # Transitions for cancel_subscription event
      expect(subscription).to transition_from(:paid).to(:canceled).on_event(:cancel_subscription)
      expect(subscription).not_to transition_from(:unpaid).to(:canceled).on_event(:cancel_subscription)
      expect(subscription).not_to transition_from(:canceled).to(:canceled).on_event(:cancel_subscription)
    end
  end
end
