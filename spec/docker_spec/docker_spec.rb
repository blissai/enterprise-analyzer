require 'pry'
require_relative './docker_spec_helper'
RSpec.describe 'docker build' do
  include DockerSpecHelper

  before(:all) do
    @passed = false
    @dckr = "#{Dir.pwd}/spec/fixtures/docker"
    @repos_path = File.expand_path('~/rspec/repos')
    FileUtils.mkdir_p(@repos_path)
    # `sudo yum update -y bliss`
    # `cd #{Dir.pwd} && docker build -t blissai/collector .`
    setup_repos
    @repos = [
      @ruby_repo, @java_repo, @dotnet_repo, @python_repo, @php_repo,
      @js_repo, @ios_repo, @elixir_repo, @scala_repo, @coffeescript_repo,
      @scss_repo, @stylus_repo, @swift_repo, @go_repo, @css_repo
    ]

    @repos.each do |r|
      `git clone #{r[:git_url]} #{r[:git_dir]}` unless File.directory?(r[:git_dir])
    end
  end

  after(:all) do
    result_files.each do |rf|
      # File.write("#{@dckr}/results/#{rf}", '')
    end
    `docker push blissai/collector` if @passed
  end

  it 'can run brakeman over a ruby project' do
    `#{bliss_lint_cmd(@brakeman)}`
  end

  it 'can run cpd over a ruby project' do
    `#{bliss_lint_cmd(@cpd)}`
  end

  it 'can run rubocop over a ruby project' do
    `#{bliss_lint_cmd(@rubocop)}`
  end

  it 'can run rbp over a ruby project' do
    `#{bliss_lint_cmd(@rbp)}`
  end

  it 'can run pmd over a java project' do
    `#{bliss_lint_cmd(@pmd)}`
  end

  it 'can run prospector over a python project' do
    `#{bliss_lint_cmd(@prospector)}`
  end

  it 'can run sonarlint over a .NET project' do
    `#{bliss_lint_cmd(@sonarlint)}`
  end

  it 'can run phpcs over a php project' do
    `#{bliss_lint_cmd(@phpcs)}`
  end

  it 'can run csslint over a css project' do
    `#{bliss_lint_cmd(@csslint)}`
  end

  it 'can run lizard over a php project' do
    `#{bliss_lint_cmd(@lizard)}`
  end

  it 'can run coffellint over a coffeescript project' do
    `#{bliss_lint_cmd(@coffeelint)}`
  end

  it 'can run jscpd_jsx over a js project' do
    `#{bliss_lint_cmd(@jscpd_jsx)}`
  end

  it 'can run eslint over a js project' do
    `#{bliss_lint_cmd(@eslint)}`
  end

  it 'can run jshint over a js project' do
    `#{bliss_lint_cmd(@jshint)}`
  end

  it 'can run nsp over a js project' do
    `#{bliss_lint_cmd(@nsp)}`
  end

  it 'can run ocstlye over an ios project' do
    `#{bliss_lint_cmd(@ocstyle)}`
  end

  it 'can run sasslint over a sass project' do
    `#{bliss_lint_cmd(@sasslint)}`
  end

  it 'can run scsslint over a sass project' do
    `#{bliss_lint_cmd(@scsslint)}`
  end

  it 'can run stylint over a stylus project' do
    `#{bliss_lint_cmd(@stylint)}`
  end

  it 'can run tailor over a swift project' do
    `#{bliss_lint_cmd(@tailor)}`
  end

  it 'can run gometalinter over a go project' do
    `#{bliss_lint_cmd(@gometalinter)}`
  end

  it 'can run credo over a elixir project' do
    `#{bliss_lint_cmd(@credo)}`
  end

  it 'can run scalastyle over a scala project' do
    `#{bliss_lint_cmd(@scalastyle)}`
    @passed = false
  end
end
