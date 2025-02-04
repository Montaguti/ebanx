# frozen_string_literal: true

module BalanceCalculator
  #
  # BalanceCalculator::Interface
  #
  class Interface
    def self.calculate
      raise NotImplementedError, "#{self.class} must implement calculate"
    end
  end
end
