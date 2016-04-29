require 'pry'
require_relative './docker_spec_helper'
RSpec.describe 'docker build', if: ENV['DOCKER_BUILD_SERVER'] do
  include DockerSpecHelper

  before(:all) do
    @dckr = "#{Dir.pwd}/spec/fixtures/docker"
    @repos_path = File.expand_path('~/rspec/repos')
    FileUtils.mkdir_p(@repos_path)
    setup_repos

    @repos.each do |r|
      `git clone #{r[:git_url]} #{r[:git_dir]}` unless File.directory?(r[:git_dir])
    end
  end

  it 'can run brakeman over a ruby project' do
    puts `#{bliss_lint_cmd(@brakeman)}`
    expect(expected_result?(@brakeman)).to eq(true)
  end

  it 'can run cpd over a ruby project' do
    puts `#{bliss_lint_cmd(@cpd)}`
    expect(expected_result?(@cpd)).to eq(true)
  end

  it 'can run rubocop over a ruby project' do
    puts `#{bliss_lint_cmd(@rubocop)}`
    expect(expected_result?(@rubocop)).to eq(true)
  end

  it 'can run rbp over a ruby project' do
    puts `#{bliss_lint_cmd(@rbp)}`
    expect(expected_result?(@rbp)).to eq(true)
  end

  it 'can run pmd over a java project' do
    puts `#{bliss_lint_cmd(@pmd)}`
    expect(expected_result?(@pmd)).to eq(true)
  end

  it 'can run prospector over a python project' do
    puts `#{bliss_lint_cmd(@prospector)}`
    expect(expected_result?(@prospector)).to eq(true)
  end

  it 'can run sonarlint over a .NET project' do
    puts `#{bliss_lint_cmd(@sonarlint)}`
    expect(expected_result?(@sonarlint)).to eq(true)
  end

  it 'can run phpcs over a php project' do
    puts `#{bliss_lint_cmd(@phpcs)}`
    expect(expected_result?(@phpcs)).to eq(true)
  end

  it 'can run csslint over a css project' do
    puts `#{bliss_lint_cmd(@csslint)}`
    expect(expected_result?(@csslint)).to eq(true)
  end

  it 'can run lizard over a php project' do
    puts `#{bliss_lint_cmd(@lizard)}`
    expect(expected_result?(@lizard)).to eq(true)
  end

  it 'can run coffellint over a coffeescript project' do
    puts `#{bliss_lint_cmd(@coffeelint)}`
    expect(expected_result?(@coffeelint)).to eq(true)
  end

  it 'can run jscpd_jsx over a js project' do
    puts `#{bliss_lint_cmd(@jscpd_jsx)}`
    expect(expected_result?(@jscpd_jsx)).to eq(true)
  end

  it 'can run eslint over a js project' do
    puts `#{bliss_lint_cmd(@eslint)}`
    expect(expected_result?(@eslint)).to eq(true)
  end

  it 'can run jshint over a js project' do
    puts `#{bliss_lint_cmd(@jshint)}`
    expect(expected_result?(@jshint)).to eq(true)
  end

  it 'can run nsp over a js project' do
    puts `#{bliss_lint_cmd(@nsp)}`
    expect(expected_result?(@nsp)).to eq(true)
  end

  it 'can run ocstlye over an ios project' do
    puts `#{bliss_lint_cmd(@ocstyle)}`
    expect(expected_result?(@ocstyle)).to eq(true)
  end

  it 'can run sasslint over a sass project' do
    puts `#{bliss_lint_cmd(@sasslint)}`
    expect(expected_result?(@sasslint)).to eq(true)
  end

  it 'can run scsslint over a sass project' do
    puts `#{bliss_lint_cmd(@scsslint)}`
    expect(expected_result?(@scsslint)).to eq(true)
  end

  it 'can run sasslint over an empty sass project' do
    puts `#{bliss_lint_cmd(@sasslint_empty)}`
    expect(expected_result?(@sasslint_empty)).to eq(true)
  end

  it 'can run stylint over a stylus project' do
    puts `#{bliss_lint_cmd(@stylint)}`
    expect(expected_result?(@stylint)).to eq(true)
  end

  it 'can run tailor over a swift project' do
    puts `#{bliss_lint_cmd(@tailor)}`
    expect(expected_result?(@tailor)).to eq(true)
  end

  it 'can run gometalinter over a go project' do
    puts `#{bliss_lint_cmd(@gometalinter)}`
    expect(expected_result?(@gometalinter)).to eq(true)
  end

  it 'can run credo over a elixir project' do
    puts `#{bliss_lint_cmd(@credo)}`
    expect(expected_result?(@credo)).to eq(true)
  end

  it 'can run scalastyle over a scala project' do
    puts `#{bliss_lint_cmd(@scalastyle)}`
    expect(expected_result?(@scalastyle)).to eq(true)
  end

  it 'can run bandit over a python project' do
    puts `#{bliss_lint_cmd(@bandit)}`
    expect(expected_result?(@bandit)).to eq(true)
  end

  it 'can run tslint over a typescript project' do
    puts `#{bliss_lint_cmd(@tslint)}`
    expect(expected_result?(@tslint)).to eq(true)
  end

  it 'can run ccm over a typescript project' do
    puts `#{bliss_lint_cmd(@ccm)}`
    expect(expected_result?(@ccm)).to eq(true)
  end

  it 'can run stats over a ruby project' do
    puts `#{bliss_stats_cmd(@rubystats)}`
    expect(expected_result?(@rubystats)).to eq(true)
  end

  it 'can run stats over a scala project' do
    puts `#{bliss_stats_cmd(@scalastats)}`
    expect(expected_result?(@scalastats)).to eq(true)
  end

  it 'can run stats over a js project' do
    puts `#{bliss_stats_cmd(@jsstats)}`
    expect(expected_result?(@jsstats)).to eq(true)
  end

  it 'can run stats over a php project' do
    puts `#{bliss_stats_cmd(@phpstats)}`
    expect(expected_result?(@phpstats)).to eq(true)
  end

  it 'can run stats over a swift project' do
    puts `#{bliss_stats_cmd(@swiftstats)}`
    expect(expected_result?(@swiftstats)).to eq(true)
  end

  it 'can run stats over a python project' do
    puts `#{bliss_stats_cmd(@pythonstats)}`
    expect(expected_result?(@pythonstats)).to eq(true)
  end

  it 'can run stats over a dotnet project' do
    puts `#{bliss_stats_cmd(@dotnetstats)}`
    expect(expected_result?(@dotnetstats)).to eq(true)
  end

  it 'can run stats over a go project' do
    puts `#{bliss_stats_cmd(@gostats)}`
    expect(expected_result?(@gostats)).to eq(true)
  end
end
