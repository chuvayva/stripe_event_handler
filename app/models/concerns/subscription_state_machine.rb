module SubscriptionStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :state do
      state :unpaid, initial: true
      state :paid
      state :canceled

      after_all_transitions :log_state_change

      event :pay_invoice do
        transitions to: :paid
      end

      event :cancel_subscription do
        transitions from: :paid, to: :canceled
      end
    end
  end

  def aasm_event_failed(event, from_state)
    Rails.logger.error "Subscription event failed: event '#{event}' is not allowed from state '#{from_state}'."
  end

  def log_state_change
    Rails.logger.info "Subscription state changed: id #{id} from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
  end
end
