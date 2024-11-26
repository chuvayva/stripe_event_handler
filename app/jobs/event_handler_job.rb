class EventHandlerJob < ApplicationJob
  queue_as :default

  def perform(event)
    EventLogic.process_event(event)
  end
end
