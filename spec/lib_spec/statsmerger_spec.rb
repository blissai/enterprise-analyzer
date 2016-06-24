require_relative '../spec_helper.rb'
RSpec.describe StatsMerger do
  before do
    allow_any_instance_of(BlissLogger).to receive(:log_to_papertrail).and_return(true)
  end

  before(:all) do
    @file_paths = []
    5.times do |i|
      @file_paths.push(File.read("spec/fixtures/stats#{i + 1}.yml"))
    end
    @keys = %w(Ruby HTML Javascript SUM MADEUP)
  end

  it 'sums up the languages correctly' do
    sm = StatsMerger.new(@file_paths)
    merged = sm.merge_files
    @keys.each do |k|
      expect(merged.key? k).to eq(true)
    end

    expect(merged['Ruby']['nFiles']).to eq(80)
    expect(merged['Ruby']['blank']).to eq(195)
    expect(merged['Ruby']['comment']).to eq(360)
    expect(merged['Ruby']['code']).to eq(1015)

    expect(merged['HTML']['nFiles']).to eq(50)
    expect(merged['HTML']['blank']).to eq(70)
    expect(merged['HTML']['comment']).to eq(105)
    expect(merged['HTML']['code']).to eq(165)

    expect(merged['Javascript']['nFiles']).to eq(15)
    expect(merged['Javascript']['blank']).to eq(20)
    expect(merged['Javascript']['comment']).to eq(10)
    expect(merged['Javascript']['code']).to eq(10)

    expect(merged['MADEUP']['nFiles']).to eq(100)
    expect(merged['MADEUP']['blank']).to eq(200)
    expect(merged['MADEUP']['comment']).to eq(300)
    expect(merged['MADEUP']['code']).to eq(410)

    expect(merged['SUM']['nFiles']).to eq(245)
    expect(merged['SUM']['blank']).to eq(485)
    expect(merged['SUM']['comment']).to eq(775)
    expect(merged['SUM']['code']).to eq(1190)
  end
end
