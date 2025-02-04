# frozen_string_literal: true

require 'bigdecimal'

require_relative './interface'

module BalanceCalculator
  # BalanceCalculator::Default
  class Default < Interface
    class << self
      def calculate(account_id, events)
        events.sum do |event|
          calculate_event_balance(event, account_id)
        end
      end

      def calculate_event_balance(event, account_id)
        case event.type
        when :deposit
          increase_balance(event, account_id)
        when :withdraw
          decrease_balance(event, account_id)
        when :transfer
          adjust_balance(event, account_id)
        end
      end

      def increase_balance(event, account_id)
        event.amount if event.destination == account_id
      end

      def decrease_balance(event, account_id)
        -event.amount if event.origin == account_id
      end

      def adjust_balance(event, account_id)
        if event.origin == account_id
          -event.amount
        elsif event.destitation == account_id
          event.amount
        end
      end
    end
  end
end
