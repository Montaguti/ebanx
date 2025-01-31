# frozen_string_literal: true

# Account entity
class Account
  attr_reader :id, :events

  def initialize(id)
    @id = id
    @events = []
  end

  def add_event(event)
    @events << event.dup.tap { |e| e&.freeze }
  end
end
