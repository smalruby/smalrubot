require 'rubyserial'

if RubySerial::ON_WINDOWS && ENV['SMALRUBOT_TIMEOUT_SCALE']
  module SerialWithTimeoutScale
    def initialize(address, baude_rate=9600, data_bits=8, parity=:none)
      super

      scale = ENV['SMALRUBOT_TIMEOUT_SCALE'].to_i.abs
      RubySerial::Win32::CommTimeouts.new.tap do |timeouts|
        timeouts[:read_interval_timeout]          = 10 * scale
        timeouts[:read_total_timeout_multiplier]  = 1 * scale
        timeouts[:read_total_timeout_constant]    = 10 * scale
        timeouts[:write_total_timeout_multiplier] = 1 * scale
        timeouts[:write_total_timeout_constant]   = 10 * scale
        err = RubySerial::Win32.SetCommTimeouts @fd, timeouts
        if err == 0
          raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[FFI.errno]
        end
      end
    end
  end

  class Serial
    prepend SerialWithTimeoutScale
  end
end

module Smalrubot
  module TxRx
    class Serial < Base
      BAUD = 19_200

      def initialize(options={})
        @device = options[:device]
        @baud = options[:baud] || BAUD
        @first_write = true
      end

      def io
        @io ||= connect
      end

      def handshake
        while tty_devices.length > 0
          begin
            if on_windows?
              io; sleep 3
            end

            return super
          rescue BoardNotFound
            @tty_devices.shift
            if @io
              @io.close
            end
            @io = nil
          end
        end
        raise BoardNotFound
      end

      private

      def connect
        tty_devices.dup.each do |device|
          begin
            serial = ::Serial.new(device, @baud)
            Smalrubot.debug_log('found board: %s (%d)', device, @baud)
            return serial
          rescue Exception
            @tty_devices.shift
            Smalrubot.debug_log('could not access: %s', device)
            Smalrubot.show_backtrace($!)
          end
        end
        raise BoardNotFound
      end

      def tty_devices
        if !@tty_devices
          if @device
            @tty_devices = [@device]
          elsif on_windows?
            @tty_devices = (1..256).map { |n| "COM#{n}" }
          else
            @tty_devices =
              `ls /dev`.split("\n").grep(/usb|ACM/i).map{ |d| "/dev/#{d}" }
          end
        end
        @tty_devices
      end

      def on_windows?
        RUBY_PLATFORM.match /mswin|mingw/i
      end
    end
  end
end
