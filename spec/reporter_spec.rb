require 'spec_helper'

RSpec.describe Reporter do
  context '#initialize' do
    it 'sets instance variables correctly' do
      options = { token: 'hello' }
      ClimateControl.modify CIRCLETOKEN: '' do
        reporter = described_class.new(options)
        expect(reporter.instance_variables.size).to eq 9
        expect(reporter.instance_variable_get(:@account)).to eq 'hopskipdrive'
        expect(reporter.instance_variable_get(:@branch)).to eq 'develop'
        expect(reporter.instance_variable_get(:@capture)).to eq false
        expect(reporter.instance_variable_get(:@input_file)).to eq nil
        expect(reporter.instance_variable_get(:@repository)).to eq 'rails-api'
        expect(reporter.instance_variable_get(:@start_date)).to eq Date.today - 7
        expect(reporter.instance_variable_get(:@report_period)).to eq Date.today - 7..Date.today - 1
        expect(reporter.errors.size).to eq 0 # has an attr_reader
      end
    end

    it 'reports mixing mutually exclusive options' do
      ClimateControl.modify CIRCLETOKEN: '' do
        options = { capture: true, input: 'not blank' }
        reporter = described_class.new(options)
        expect(reporter.errors.size).to eq 1
        expect(reporter.errors).to include "You can't use both capture and input at the same time"
      end
    end

    it 'reports missing token' do
      ClimateControl.modify CIRCLETOKEN: '' do
        options = {}
        reporter = described_class.new(options)
        expect(reporter.errors.size).to eq 1
        expect(reporter.errors).to include "Circle Token missing. Use --token or environment variable 'CIRCLETOKEN'."
      end
    end

    it 'reports an invalid start date' do
      options = { token: 'hello', start: 'hello again' }
      reporter = described_class.new(options)
      expect(reporter.errors.size).to eq 1
      expect(reporter.errors).to include 'Invalid start date: hello again'
    end
  end

  context '#circle_data' do
    it 'responds with a 404 if the token is invalid' do
      options = { token: 'not good' }
      reporter = described_class.new(options)
      expect(reporter.errors.size).to be_zero
      VCR.use_cassette('circle_data_invalid_token') do
        reporter.send(:circle_data)
      end
      expect(reporter.errors.size).to eq 1
      expect(reporter.errors[0]).to eq "Error retrieving from CircleCI:\n"\
                                       "    404 Not Found.\n"\
                                       '    404 Not Found may indicate a problem with your Circle Token.'
    end
  end

  context '#file_data' do
    it 'reports an error if the file name is invalid' do
      options = { input: 'not good' }
      reporter = described_class.new(options)
      expect(reporter.errors.size).to be_zero
      reporter.send(:file_data)
      expect(reporter.errors.size).to eq 1
      expect(reporter.errors[0]).to eq "Error reading from file: not good\n"\
                                       '    No such file or directory @ rb_sysopen - not good'
    end
  end

  context '#report' do
    it 'produces output' do
      options = { input: './spec/fixtures/circle_data_1.json', start: '2020-06-03' }
      reporter = described_class.new(options)
      output_lines, raw_results = reporter.report
      expect(output_lines.size).to eq 9
      expect(raw_results[:success]).to eq 24
      expect(raw_results[:fail]).to eq 2
      expect(raw_results[:percent_success]).to eq 92.31
      expect(raw_results[:percent_fail]).to eq 7.69
    end

    it 'produces zeros if no data falls inside range' do
      options = { input: './spec/fixtures/circle_data_1.json', start: '2020-01-01' }
      reporter = described_class.new(options)
      output_lines, raw_results = reporter.report
      expect(output_lines.size).to eq 3
      expect(raw_results[:success]).to eq 0
      expect(raw_results[:fail]).to eq 0
      expect(raw_results).to_not have_key(:percent_success)
      expect(raw_results).to_not have_key(:percent_fail)
    end
  end
end
