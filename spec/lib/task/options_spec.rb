require 'spec_helper'
require 'alfred/task/options'

describe Alfred::Task::Options do
  let(:klass) { DummyTask }

  describe '.define_parser' do
    it 'returns an instance of Alfred::Parser' do
      expect(klass.define_parser).to be_kind_of(Alfred::Parser)
    end
  end

  describe '.parse_options!' do
    let(:klass) do
      Class.new(DummyTask) do
        parser do
          on('-i', '--install') do |i|
            options[:install] = i
          end
        end
      end
    end

    let(:arguments) { ['arg1', 'arg2', '--install'] }

    let(:expected) do
      ['arg1', 'arg2', { install: true }]
    end
    it 'returns the correct arguments and options' do
      expect(klass.parse_options!(arguments)).to be_eql(expected)
    end
  end
end