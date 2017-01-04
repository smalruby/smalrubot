require 'spec_helper'

module Smalrubot
  module Components
    describe Led do
      let(:board) { double(:board, digital_write: true, set_pin_mode: true) }

      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect {
            Led.new(board: board)
          }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect {
            Led.new(pins: {})
          }.to raise_exception
        end

        it 'should set the pin to out' do
          expect(board).to receive(:set_pin_mode).with(13, :out, nil)
          Led.new(pin: 13, board: board)
        end

        it 'should set the pin to low' do
          expect(board).to receive(:digital_write).with(13, Board::LOW)
          Led.new(pin: 13, board: board)
        end
      end

      describe '#on' do
        it 'should send a high to the board with the pin' do
          @led = Led.new(pin: 13, board: board)
          expect(board).to receive(:digital_write).with(13, Board::HIGH)
          @led.on
        end
      end

      describe '#off' do
        it 'should send a high to the board with the pin' do
          @led = Led.new(pin: 13, board: board)
          expect(board).to receive(:digital_write).with(13, Board::LOW)
          @led.off
        end
      end
    end
  end
end
