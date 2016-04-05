require 'pry'
RSpec.describe 'docker build', if: ENV['DOCKER_BUILD_SERVER'] do
  before(:all) do
    @passed = false
    @dckr = "#{Dir.pwd}/spec/fixtures/docker"
    @repos_path = File.expand_path('~/rspec/repos')
    FileUtils.mkdir_p(@repos_path)
    `sudo yum update -y bliss`
    `cd #{Dir.pwd} && docker build -t blissai/collector .`

    @ruby_repo = {
      git_dir: "#{@repos_path}/rails",
      git_url: 'https://github.com/iconnor/simple_rails.git',
      commit: '06e2f784f085e0548229f7dd87bf2bbc80296541',
      excluded_dirs: 'excluded_dirs=public,vendor,bin,coverage,db,config',
      remove_os: true
    }

    @java_repo = {
      git_dir: "#{@repos_path}/java",
      git_url: 'https://github.com/iconnor/simple_java.git',
      excluded_dirs: '',
      remove_os: true
    }

    @dotnet_repo = {
      git_dir: "#{@repos_path}/dotnet",
      git_url: 'https://github.com/iconnor/simple_dotnet.git',
      excluded_dirs: '',
      remove_os: true
    }

    @python_repo = {
      git_dir: "#{@repos_path}/django",
      git_url: 'https://github.com/iconnor/django-test.git',
      excluded_dirs: '',
      remove_os: true
    }

    @php_repo = {
      git_dir: "#{@repos_path}/php",
      git_url: 'https://github.com/iconnor/simple_wp.git',
      excluded_dirs: '',
      remove_os: true
    }

    @coffeescript_repo = {
      git_dir: "#{@repos_path}/coffee",
      git_url: 'https://github.com/atom/atom.git',
      excluded_dirs: '',
      remove_os: false
    }

    @js_repo = {
      git_dir: "#{@repos_path}/js",
      git_url: 'https://github.com/rarescarab/flock.git',
      excluded_dirs: '',
      remove_os: false
    }

    @ios_repo = {
      git_dir: "#{@repos_path}/ios",
      git_url: 'https://github.com/iconnor/simple_iphone.git',
      excluded_dirs: '',
      remove_os: true
    }

    @scss_repo = {
      git_dir: "#{@repos_path}/scss",
      git_url: 'https://github.com/kristerkari/normalize.scss.git',
      excluded_dirs: '',
      remove_os: false
    }

    @stylus_repo = {
      git_dir: "#{@repos_path}/stylus",
      git_url: 'https://github.com/maxmx/bootstrap-stylus.git',
      excluded_dirs: '',
      remove_os: false
    }

    @swift_repo = {
      git_dir: "#{@repos_path}/swift",
      git_url: 'https://github.com/SwiftyJSON/SwiftyJSON.git',
      excluded_dirs: '',
      remove_os: false
    }

    @go_repo = {
      git_dir: "#{@repos_path}/go",
      git_url: 'https://github.com/spf13/hugo.git',
      excluded_dirs: '',
      remove_os: false
    }

    @elixir_repo = {
      git_dir: "#{@repos_path}/elixir",
      git_url: 'git clone https://github.com/thoughtbot/bamboo.git',
      excluded_dirs: '',
      remove_os: false
    }

    @elixir_repo = {
      git_dir: "#{@repos_path}/elixir",
      git_url: 'git clone https://github.com/thoughtbot/bamboo.git',
      excluded_dirs: '',
      remove_os: false
    }

    @scala_repo = {
      git_dir: "#{@repos_path}/scala",
      git_url: 'git clone https://github.com/akka/akka.git',
      excluded_dirs: '',
      remove_os: false
    }

    @brakeman = { linter: "#{@dckr}/brakeman.yml", result: "#{@dckr}/brakeman_result.txt" }.merge(@ruby_repo)
    @cpd = { linter: "#{@dckr}/cpd.yml", result: "#{@dckr}/cpd-ruby_result.txt" }.merge(@ruby_repo)
    @rubocop = { linter: "#{@dckr}/rubocop.yml", result: "#{@dckr}/rubocop_result.txt" }.merge(@ruby_repo)
    @rbp = { linter: "#{@dckr}/rbp.yml", result: "#{@dckr}/rbp_result.txt" }.merge(@ruby_repo)
    @pmd = { linter: "#{@dckr}/pmd.yml", result: "#{@dckr}/pmd_result.txt" }.merge(@java_repo)
    @sonarlint = { linter: "#{@dckr}/sonarlint.yml", result: "#{@dckr}/sonarlint_result.txt" }.merge(@dotnet_repo)
    @prospector = { linter: "#{@dckr}/prospector.yml", result: "#{@dckr}/prospector_result.txt" }.merge(@python_repo)
    @phpcs = { linter: "#{@dckr}/phpcs.yml", result: "#{@dckr}/phpcs_result.txt" }.merge(@php_repo)
    @csslint = { linter: "#{@dckr}/csslint.yml", result: "#{@dckr}/csslint_result.txt" }.merge(@php_repo)
    @lizard = { linter: "#{@dckr}/lizard.yml", result: "#{@dckr}/lizard_result.txt" }.merge(@php_repo)
    @coffeelint = { linter: "#{@dckr}/coffeelint.yml", result: "#{@dckr}/coffeelint_result.txt" }.merge(@coffeescript_repo)
    @jscpd_jsx = { linter: "#{@dckr}/jscpdjsx.yml", result: "#{@dckr}/jscpd-jsx_result.txt" }.merge(@js_repo)
    @eslint = { linter: "#{@dckr}/eslint.yml" }.merge(@js_repo)
    @jshint = { linter: "#{@dckr}/jshint.yml" }.merge(@js_repo)
    @nsp = { linter: "#{@dckr}/nsp.yml" }.merge(@js_repo)
    @ocstyle = { linter: "#{@dckr}/ocstyle.yml" }.merge(@ios_repo)
    @sasslint = { linter: "#{@dckr}/sasslint.yml" }.merge(@scss_repo)
    @scsslint = { linter: "#{@dckr}/scsslint.yml" }.merge(@scss_repo)
    @stylint = { linter: "#{@dckr}/stylint.yml" }.merge(@stylus_repo)
    @tailor = { linter: "#{@dckr}/tailor.yml" }.merge(@swift_repo)
    @gometalinter = { linter: "#{@dckr}/gometalinter.yml" }.merge(@go_repo)
    @credo = { linter: "#{@dckr}/credo.yml" }.merge(@elixir_repo)
    @scala = { linter: "#{@dckr}/scalastyle.yml" }.merge(@scala_repo)

    @repos = [@ruby_repo, @java_repo, @dotnet_repo, @python_repo, @php_repo]

    @repos.each do |r|
      `git clone #{r[:git_url]} #{r[:git_dir]}` unless File.directory?(r[:git_dir])
      File.write(r[:result], '')
    end
  end

  after(:all) do
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
  end

  def result_files
    [
      'brakeman_result.txt', 'coffeelint_result.txt',
      'cpd-ruby_result.txt', 'credo_result.txt',
      'csslint_result.txt', 'eslint_result.txt',
      'eslint-airbnb_result.txt', 'gometalinter_result.txt',
      'jscpd-jsx_result.txt', 'jshint_result.txt',
      'lizard_result.txt', 'nsp_result.txt',
      'phpcs_result.txt', 'ocstyle_result.txt',
      'pmd_result.txt', 'tailor_result.txt',
      'prospector_result.txt', 'rbp_result.txt',
      'rubocop_result.txt', 'sass-lint_result.txt',
      'scalastyle_result.txt', 'scss-lint_result.txt',
      'sonarlint_result.txt', 'stylint_result.txt',
    ]
  end

  def bliss_lint_cmd(repo)
    "bliss lint dir=#{repo[:git_dir]} linter_config_path=#{repo[:linter]} log=\"enterprise_rspec\" output_file=#{repo[:result]} commit=#{repo[:commit]} #{repo[:excluded_dirs]} remove_open_source=#{repo[:remove_os]}"
  end

  def bliss_stats_cmd(repo)
    "bliss stats dir=#{repo[:git_dir]} output_file=#{repo[:result]} commit=#{repo[:commit]} repo_test_files=test repo_test_dirs=test,spec remove_open_source=#{repo[:remove_os]}"
  end
end
