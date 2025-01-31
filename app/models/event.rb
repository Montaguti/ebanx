# frozen_string_literal: true

require 'bigdecimal'
require 'securerandom'

require_relative './event/errors'

# Event entity
class Event
  TYPE_OPTIONS = %w[deposit withdraw transfer].freeze
  private_constant :TYPE_OPTIONS

  attr_reader :type, :origin, :destination, :amount,
              :timestamp, :uuid

  def initialize(type:, amount:, destination: nil, origin: nil)
    @type = validate_type(type)
    @destination = destination&.to_s
    @origin = origin&.to_s
    @amount = BigDecimal(amount.to_s)
    @timestamp = Time.now
    @uuid = SecureRandom.uuid
  end

  private

  def validate_type(type)
    raise Event::InvalidTypeError unless TYPE_OPTIONS.include?(type.to_s)

    type.to_sym
  end
end
