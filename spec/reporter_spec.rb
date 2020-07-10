require 'spec_helper'

RSpec.describe Reporter do
  context '#initialize' do
    it 'sets instance variables correctly' do
      options = {}
      reporter = described_class.new(options)
      expect(reporter.instance_variable_get(:@account)).to eq 'hopskipdrive'
      expect(reporter.instance_variable_get(:@branch)).to eq 'develop'
      expect(reporter.instance_variable_get(:@capture)).to eq false
      expect(reporter.instance_variable_get(:@input_file)).to eq nil
      expect(reporter.instance_variable_get(:@repository)).to eq 'rails-api'
      expect(reporter.instance_variable_get(:@start_date)).to eq Date.today - 7
      expect(reporter.errors).to eq []
    end

    it 'reports errors' do
      ClimateControl.modify CIRCLETOKEN: '' do
        options = { capture: true, input: 'not blank' }
        reporter = described_class.new(options)
        expect(reporter.errors.size).to eq 2
        expect(reporter.errors).to include "You can't use both capture and input at the same time"
        expect(reporter.errors).to include "Circle Token missing. Use --token or environment variable 'CIRCLETOKEN'."
      end
    end
  end

  context '#report' do
    it 'produces output' do
      options = { input: 'fixtures/circle_data_2020-6-11T09:57:28-07:00.json' }
      reporter = described_class.new(options)
      reporter.report
    end
  end
end
