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
    "bliss lint dir=#{repo[:git_dir]} linter_config_path=#{repo[:linter]} " \
    "log=\"enterprise_rspec\" output_file=#{repo[:result]} commit=#{repo[:commit]} " \
    "#{repo[:excluded_dirs]} remove_open_source=#{repo[:remove_os]}"
  end

  def bliss_stats_cmd(repo)
    "bliss stats dir=#{repo[:git_dir]} output_file=#{repo[:result]} commit=#{repo[:commit]} " \
    "repo_test_files=test repo_test_dirs=test,spec remove_open_source=#{repo[:remove_os]}"
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

    @brakeman = {
      linter: "#{@dckr}/brakeman.yml",
      result: "#{@dckr}/brakeman_result.txt"
    }.merge(@ruby_repo)

    @cpd = {
      linter: "#{@dckr}/cpd.yml",
      result: "#{@dckr}/cpd-ruby_result.txt"
    }.merge(@ruby_repo)

    @rubocop = {
      linter: "#{@dckr}/rubocop.yml",
      result: "#{@dckr}/rubocop_result.txt"
    }.merge(@ruby_repo)

    @rbp = {
      linter: "#{@dckr}/rbp.yml",
      result: "#{@dckr}/rbp_result.txt"
    }.merge(@ruby_repo)

    @pmd = {
      linter: "#{@dckr}/pmd.yml",
      result: "#{@dckr}/pmd_result.txt"
    }.merge(@java_repo)

    @sonarlint = {
      linter: "#{@dckr}/sonarlint.yml",
      result: "#{@dckr}/sonarlint_result.txt"
    }.merge(@dotnet_repo)

    @prospector = {
      linter: "#{@dckr}/prospector.yml",
      result: "#{@dckr}/prospector_result.txt"
    }.merge(@python_repo)

    @phpcs = {
      linter: "#{@dckr}/phpcs.yml",
      result: "#{@dckr}/phpcs_result.txt"
    }.merge(@php_repo)

    @csslint = {
      linter: "#{@dckr}/csslint.yml",
      result: "#{@dckr}/csslint_result.txt"
    }.merge(@php_repo)

    @lizard = {
      linter: "#{@dckr}/lizard.yml",
      result: "#{@dckr}/lizard_result.txt"
    }.merge(@php_repo)

    @coffeelint = {
      linter: "#{@dckr}/coffeelint.yml",
      result: "#{@dckr}/coffeelint_result.txt"
    }.merge(@coffeescript_repo)

    @jscpd_jsx = {
      linter: "#{@dckr}/jscpdjsx.yml",
      result: "#{@dckr}/jscpd-jsx_result.txt"
    }.merge(@js_repo)

    @eslint = {
      linter: "#{@dckr}/eslint.yml",
      result: "#{@dckr}/eslint_result.txt"
    }.merge(@js_repo)

    @jshint = {
      linter: "#{@dckr}/jshint.yml",
      result: "#{@dckr}/jshint_result.txt"
    }.merge(@js_repo)

    @nsp = {
      linter: "#{@dckr}/nsp.yml",
      result: "#{@dckr}/nsp_result.txt"
    }.merge(@js_repo)

    @ocstyle = {
      linter: "#{@dckr}/ocstyle.yml",
      result: "#{@dckr}/ocstyle_result.txt"
    }.merge(@ios_repo)

    @sasslint = {
      linter: "#{@dckr}/sasslint.yml",
      result: "#{@dckr}/sass-lint_result.txt"
    }.merge(@scss_repo)

    @scsslint = {
      linter: "#{@dckr}/scsslint.yml",
      result: "#{@dckr}/scss-lint_result.txt"
    }.merge(@scss_repo)

    @stylint = {
      linter: "#{@dckr}/stylint.yml",
      result: "#{@dckr}/stylint_result.txt"
    }.merge(@stylus_repo)

    @tailor = {
      linter: "#{@dckr}/tailor.yml",
      result: "#{@dckr}/tailor_result.txt"
    }.merge(@swift_repo)

    @gometalinter = {
      linter: "#{@dckr}/gometalinter.yml",
      result: "#{@dckr}/gometalinter_result.txt"
    }.merge(@go_repo)

    @credo = {
      linter: "#{@dckr}/credo.yml",
      result: "#{@dckr}/credo_result.txt"
    }.merge(@elixir_repo)

    @scala = {
      linter: "#{@dckr}/scalastyle.yml",
      result: "#{@dckr}/scalastyle.txt"
    }.merge(@scala_repo)
  end
end
