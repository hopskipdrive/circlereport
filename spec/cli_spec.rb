require 'spec_helper'

RSpec.describe HsdCircleReports::Report do
  context 'the whole enchilada' do
    before do
      subject.options = {
        input: "./spec/fixtures/circle_data_1.json",
        start: '2020-06-11'
      }
    end
    let(:expected_results) do
      "Report Period: 2020-06-11..2020-06-17\n"\
      "Reading from file #{subject.options[:input]}\n"\
      "Date: 2020-06-11 Successful builds: 2 other builds: 0\n\n"\
      "Passing builds: 2. Failing builds: 0\n"
    end
    let(:output) { capture_stdout { subject.build_stats } }

    it 'runs ok' do
      expect(output).to eq expected_results
    end
  end
end
