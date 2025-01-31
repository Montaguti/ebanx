# frozen_string_literal: true

class Event
  # Event::InvalidTypeError
  class InvalidTypeError < StandardError
    def initialize(msg = 'Invalid event type')
      super
    end
  end
end
