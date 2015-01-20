module Smalrubot
  module TxRx
    require 'smalrubot/tx_rx/base'
    require 'smalrubot/tx_rx/serial'
    require 'smalrubot/tx_rx/tcp'

    def self.new(options={})
      self::Serial.new(options)
    end
  end
end
