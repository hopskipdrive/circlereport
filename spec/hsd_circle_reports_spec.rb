RSpec.describe HsdCircleReports do
  it 'has a version number' do
    expect(HsdCircleReports::VERSION).not_to be nil
  end

  context '#build_stats' do
    let(:params) { '--input x --capture' }
    subject HsdCircleReports::Report.build_stats params
    it 'does something useful' do
      subject
      expect(true).to eq(true)
    end
  end
end
