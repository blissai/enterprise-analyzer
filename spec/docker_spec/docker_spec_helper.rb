module DockerSpecHelper
  def result_files
    [
      'brakeman_result.txt', 'coffeelint_result.txt', 'cpd-ruby_result.txt', 'credo_result.txt',
      'csslint_result.txt', 'eslint_result.txt', 'gometalinter_result.txt', 'stylint_result.txt',
      'jscpd-jsx_result.txt', 'jshint_result.txt', 'lizard_result.txt', 'nsp_result.txt',
      'phpcs_result.txt', 'ocstyle_result.txt', 'pmd_result.txt', 'tailor_result.txt',
      'prospector_result.txt', 'rbp_result.txt', 'rubocop_result.txt', 'sass-lint_result.txt',
      'scalastyle_result.txt', 'scss-lint_result.txt', 'sonarlint_result.txt'
    ]
  end

  def bliss_lint_cmd(repo)
    cmd = "bliss lint dir=#{repo[:git_dir]} linter_config_path=#{repo[:linter]} " \
    "log=\"enterprise_rspec\" output_file=#{repo[:result]} commit=#{repo[:commit]} " \
    "#{repo[:excluded_dirs]} remove_open_source=#{repo[:remove_os]}"
    puts "Running #{cmd}"
    cmd
  end

  def bliss_stats_cmd(repo)
    cmd = "bliss stats dir=#{repo[:git_dir]} output_file=#{repo[:result]} commit=#{repo[:commit]} " \
    "repo_test_files=test repo_test_dirs=test,spec remove_open_source=#{repo[:remove_os]}"
    puts "Running #{cmd}"
    cmd
  end

  def setup_repos
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
      commit: 'bac210ce7b8080118d74c9754ac828b1ef625a4f',
      excluded_dirs: '',
      remove_os: true
    }

    @dotnet_repo = {
      git_dir: "#{@repos_path}/dotnet",
      git_url: 'https://github.com/iconnor/simple_dotnet.git',
      commit: '36a679d4cc20c5df40da26ca2d345fc85055b0aa',
      excluded_dirs: '',
      remove_os: true
    }

    @python_repo = {
      git_dir: "#{@repos_path}/django",
      git_url: 'https://github.com/iconnor/django-test.git',
      commit: 'bfee08adb3d5de51fe0ebb69f55e83b2282e2951',
      excluded_dirs: '',
      remove_os: true
    }

    @php_repo = {
      git_dir: "#{@repos_path}/php",
      git_url: 'https://github.com/iconnor/simple_wp.git',
      commit: '8ea2ececefa6ae3088182ac4e9b72bf9e576f5ad',
      excluded_dirs: '',
      remove_os: false
    }

    @coffeescript_repo = {
      git_dir: "#{@repos_path}/coffee",
      git_url: 'https://github.com/atom/atom.git',
      commit: 'f638bcbb6d97a27a90d9d8b780659eb61d87de55',
      excluded_dirs: '',
      remove_os: false
    }

    @js_repo = {
      git_dir: "#{@repos_path}/js",
      git_url: 'https://github.com/rarescarab/flock.git',
      commit: '5b7224dfd0b74e3033950d5f73d9368ee0e33032',
      excluded_dirs: '',
      remove_os: false
    }

    @ios_repo = {
      git_dir: "#{@repos_path}/ios",
      git_url: 'https://github.com/iconnor/simple_iphone.git',
      commit: 'd233213b125e7821e5db591cd3fb41ac0c3a8221',
      excluded_dirs: '',
      remove_os: true
    }

    @scss_repo = {
      git_dir: "#{@repos_path}/scss",
      git_url: 'https://github.com/kristerkari/normalize.scss.git',
      commit: '74eb24e4d3b2f86b2cb3ca7e0f553cf277fc695b',
      excluded_dirs: '',
      remove_os: false
    }

    @stylus_repo = {
      git_dir: "#{@repos_path}/stylus",
      git_url: 'https://github.com/maxmx/bootstrap-stylus.git',
      commit: '75eea475ab8a4219c8daa6c50a7930657778bc4d',
      excluded_dirs: '',
      remove_os: false
    }

    @swift_repo = {
      git_dir: "#{@repos_path}/swift",
      git_url: 'https://github.com/SwiftyJSON/SwiftyJSON.git',
      commit: '20ee3ed7bd9e49c250d91f402f01fe87caeacf2a',
      excluded_dirs: '',
      remove_os: false
    }

    @go_repo = {
      git_dir: "#{@repos_path}/go",
      git_url: 'https://github.com/spf13/hugo.git',
      commit: '43b5dfabb5fb36bb4574289912c66a46ef20ffce',
      excluded_dirs: '',
      remove_os: false
    }

    @elixir_repo = {
      git_dir: "#{@repos_path}/elixir",
      git_url: 'https://github.com/thoughtbot/bamboo.git',
      commit: '709457976189dfcef057f6d1522d5398264aa2d3',
      excluded_dirs: '',
      remove_os: false
    }

    @scala_repo = {
      git_dir: "#{@repos_path}/scala",
      git_url: 'https://github.com/akka/akka.git',
      commit: '60c8648b591966701791d1a2106d5168d4f7d6bd',
      excluded_dirs: '',
      remove_os: false
    }

    @brakeman = {
      linter: "#{@dckr}/linters/brakeman.yml",
      result: "#{@dckr}/results/brakeman_result.txt",
      expected: "#{@dckr}/expected_results/brakeman_result.txt"
    }.merge(@ruby_repo)

    @cpd = {
      linter: "#{@dckr}/linters/cpd.yml",
      result: "#{@dckr}/results/cpd-php_result.txt",
      expected: "#{@dckr}/expected_results/cpd-php_result.txt"
    }.merge(@php_repo)

    @rubocop = {
      linter: "#{@dckr}/linters/rubocop.yml",
      result: "#{@dckr}/results/rubocop_result.txt",
      expected: "#{@dckr}/expected_results/runocop_result.txt"
    }.merge(@ruby_repo)

    @rbp = {
      linter: "#{@dckr}/linters/rbp.yml",
      result: "#{@dckr}/results/rbp_result.txt",
      expected: "#{@dckr}/expected_results/rbp_result.txt"
    }.merge(@ruby_repo)

    @pmd = {
      linter: "#{@dckr}/linters/pmd.yml",
      result: "#{@dckr}/results/pmd_result.txt",
      expected: "#{@dckr}/expected_results/pmd_result.txt"
    }.merge(@java_repo)

    @sonarlint = {
      linter: "#{@dckr}/linters/sonarlint.yml",
      result: "#{@dckr}/results/sonarlint_result.txt",
      expected: "#{@dckr}/expected_results/sonarlint_result.txt"
    }.merge(@dotnet_repo)

    @prospector = {
      linter: "#{@dckr}/linters/prospector.yml",
      result: "#{@dckr}/results/prospector_result.txt",
      expected: "#{@dckr}/expected_results/prospector_result.txt"
    }.merge(@python_repo)

    @phpcs = {
      linter: "#{@dckr}/linters/phpcs.yml",
      result: "#{@dckr}/results/phpcs_result.txt",
      expected: "#{@dckr}/expected_results/phpcs_result.txt"
    }.merge(@php_repo)

    @csslint = {
      linter: "#{@dckr}/linters/csslint.yml",
      result: "#{@dckr}/results/csslint_result.txt",
      expected: "#{@dckr}/expected_results/csslint_result.txt"
    }.merge(@js_repo)

    @lizard = {
      linter: "#{@dckr}/linters/lizard.yml",
      result: "#{@dckr}/results/lizard_result.txt",
      expected: "#{@dckr}/expected_results/lizard_result.txt"
    }.merge(@php_repo)

    @coffeelint = {
      linter: "#{@dckr}/linters/coffeelint.yml",
      result: "#{@dckr}/results/coffeelint_result.txt",
      expected: "#{@dckr}/expected_results/coffeelint_result.txt"
    }.merge(@coffeescript_repo)

    @jscpd_jsx = {
      linter: "#{@dckr}/linters/jscpdjsx.yml",
      result: "#{@dckr}/results/jscpd-jsx_result.txt",
      expected: "#{@dckr}/expected_results/jscpd-jsx_result.txt"
    }.merge(@js_repo)

    @eslint = {
      linter: "#{@dckr}/linters/eslint.yml",
      result: "#{@dckr}/results/eslint_result.txt",
      expected: "#{@dckr}/expected_results/eslint_result.txt"
    }.merge(@js_repo)

    @jshint = {
      linter: "#{@dckr}/linters/jshint.yml",
      result: "#{@dckr}/results/jshint_result.txt",
      expected: "#{@dckr}/expected_results/jshint_result.txt"
    }.merge(@js_repo)

    @nsp = {
      linter: "#{@dckr}/linters/nsp.yml",
      result: "#{@dckr}/results/nsp_result.txt",
      expected: "#{@dckr}/expected_results/nsp_result.txt"
    }.merge(@js_repo)

    @ocstyle = {
      linter: "#{@dckr}/linters/ocstyle.yml",
      result: "#{@dckr}/results/ocstyle_result.txt",
      expected: "#{@dckr}/expected_results/ocstyle_result.txt"
    }.merge(@ios_repo)

    @sasslint = {
      linter: "#{@dckr}/linters/sasslint.yml",
      result: "#{@dckr}/results/sass-lint_result.txt",
      expected: "#{@dckr}/expected_results/sass-lint_result.txt"
    }.merge(@scss_repo)

    @scsslint = {
      linter: "#{@dckr}/linters/scsslint.yml",
      result: "#{@dckr}/results/scss-lint_result.txt",
      expected: "#{@dckr}/expected_results/scss-lint_result.txt"
    }.merge(@scss_repo)

    @stylint = {
      linter: "#{@dckr}/linters/stylint.yml",
      result: "#{@dckr}/results/stylint_result.txt",
      expected: "#{@dckr}/expected_results/stylint_result.txt"
    }.merge(@stylus_repo)

    @tailor = {
      linter: "#{@dckr}/linters/tailor.yml",
      result: "#{@dckr}/results/tailor_result.txt",
      expected: "#{@dckr}/expected_results/tailor_result.txt"
    }.merge(@swift_repo)

    @gometalinter = {
      linter: "#{@dckr}/linters/gometalinter.yml",
      result: "#{@dckr}/results/gometalinter_result.txt",
      expected: "#{@dckr}/expected_results/gometalinter_result.txt"
    }.merge(@go_repo)

    @credo = {
      linter: "#{@dckr}/linters/credo.yml",
      result: "#{@dckr}/results/credo_result.txt",
      expected: "#{@dckr}/expected_results/credo_result.txt"
    }.merge(@elixir_repo)

    @scalastyle = {
      linter: "#{@dckr}/linters/scalastyle.yml",
      result: "#{@dckr}/results/scalastyle.txt",
      expected: "#{@dckr}/expected_results/scalastyle_result.txt"
    }.merge(@scala_repo)
  end
end
