require 'spec_helper'

module Smalrubot
  describe TxRx::Serial do
    it { should be }

    describe '#initialize' do
      it 'should set first_write to true' do
        expect(TxRx::Serial.new.instance_variable_get(:@first_write)).to eq(true)
      end

      it 'should set the device and buad if specified' do
        txrx = TxRx::Serial.new({device: "/dev/ttyACM0", baud: 9600})
        expect(txrx.instance_variable_get(:@baud)).to eq(9600)
        expect(txrx.instance_variable_get(:@device)).to eq("/dev/ttyACM0")
      end
    end

    describe '#io' do
      context "on windows" do
        it 'should instantiate a new ::Serial for the first available tty device' do
          original_platform = RUBY_PLATFORM
          Constants.redefine(:RUBY_PLATFORM, "mswin", :on => Object)
          subject.instance_variable_set('@tty_devices', ["COM1", "COM2", "COM3"])

          # COM2 is chosen as available for this test.
          expect(::Serial).to receive(:new).with("COM1", TxRx::Serial::BAUD).and_raise
          expect(::Serial).to receive(:new).with("COM2", TxRx::Serial::BAUD).and_return(mock_serial = double)
          expect(::Serial).not_to receive(:new).with("COM3", TxRx::Serial::BAUD)

          expect(subject.io).to eq(mock_serial)
          Constants.redefine(:RUBY_PLATFORM, original_platform, :on => Object)
        end
      end

      context "on unix" do
        it 'should instantiate a new ::Serial for the first available tty device' do
          expect(subject).to receive(:tty_devices).and_return(['/dev/ttyACM0', '/dev/tty.usbmodem1'])

          # /dev/ttyACM0 is chosen as available for this test.
          expect(::Serial).to receive(:new).with('/dev/ttyACM0', TxRx::Serial::BAUD).and_return(mock_serial = double)
          expect(::Serial).not_to receive(:new).with('/dev/tty.usbmodem1', TxRx::Serial::BAUD)

          expect(subject.io).to eq(mock_serial)
        end
      end

      it 'should connect to the specified device at the specified baud rate' do
        expect(subject).to receive(:tty_devices).and_return(["/dev/ttyACM0"])
        expect(::Serial).to receive(:new).with('/dev/ttyACM0', 9600).and_return(mock_serial = double)

        subject.instance_variable_set(:@device, "/dev/ttyACM0")
        subject.instance_variable_set(:@baud, 9600)

        expect(subject.io).to eq(mock_serial)
      end

      it 'should use the existing io instance if set' do
        expect(subject).to receive(:tty_devices).once.and_return(['/dev/tty.ACM0', '/dev/tty.usbmodem1'])
        allow(::Serial).to receive(:new).and_return(mock_serial = double)

        3.times { subject.io }
        expect(subject.io).to eq(mock_serial)
      end

      it 'should raise a BoardNotFound exception if there is no board connected' do
        allow(::Serial).to receive(:new).and_raise
        expect { subject.io }.to raise_exception BoardNotFound
      end
    end

    describe '#write' do
      it 'should write to the device' do
        allow(subject).to receive(:io).and_return(mock_serial = double)
        msg = 'a message'
        expect(mock_serial).to receive(:write).with(msg).and_return(msg.length)
        subject.write('a message')
      end
    end
  end
end
