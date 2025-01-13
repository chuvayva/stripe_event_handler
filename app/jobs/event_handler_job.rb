class EventHandlerJob < ApplicationJob
  queue_as :default

  def perform(**options)
    EventLogic.process_event(**options)
  end
end
