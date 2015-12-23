class LintInstaller
  def initialize(languages, logger)
    @logger = logger
    @logger.info("Installing linters...")
    @languages = languages
  end

  def run
    install_dependencies
  end

  def css_dependencies
    begin
      if `npm list -g csslint`.include? "empty"
        puts "Installing csslint...".blue
        `npm install -g csslint`
      end
    rescue Errno::ENOENT
      @logger.error("Dependency Error: Node not installed...")
      abort "Node Package Manager not installed. Please install NodeJS and NPM and make sure it is added to your PATH".red
    end
  end

  def php_dependencies
    begin
      `php -v`
      if !File.directory?(File.expand_path("~/phpcs"))
        @logger.info("Installing PHP Codesniffer...")
        `git clone https://github.com/squizlabs/PHP_CodeSniffer.git #{File.expand_path("~/phpcs")}`
        # install php codesniffer
      end
    rescue Errno::ENOENT
      @logger.error("Dependency Error: PHP not installed...")
      abort "PHP not installed. Please install PHP and make sure it is added to your PATH".red
    end
  end

  def wordpress_dependencies
    # install php codesniffer if not exists
    php_dependencies
    # install wpcs if not exists
    if !File.directory?(File.expand_path("~/wpcs"))
      @logger.info("Installing Wordpress Codesniffer...")
      `git clone https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git #{File.expand_path("~/wpcs")}`
      # point php codesniffer to wpcs
      `#{File.expand_path("~/phpcs/scripts/phpcs")} --config-set installed_paths #{File.expand_path("~/wpcs")}`
    end
  end

  def js_dependencies
    begin
      if `npm list -g jshint`.include? "empty"
        puts "Installing jsHint...".blue
        `npm install -g jshint`
        `npm install --save-dev jshint-json`
      end
    rescue Errno::ENOENT
      @logger.error("Dependency Error: Node not installed...")
      abort "Node Package Manager not installed. Please install NodeJS and NPM and make sure it is added to your PATH".red
    end
  end

  def python_dependencies
    begin
      if !`pip freeze`.include?('django') || !`pip freeze`.include?('prospector')
        @logger.info("Installing Django and Prospector...")
        `pip install --user django`
        `pip install --user prospector`
      end
    rescue Errno::ENOENT
      @logger.error("Dependency Error: Python not installed...")
      abort "Python not installed. Please install Python and make sure it is added to your PATH.".red
    end
  end

  def c_dependencies
    begin
      if (!`pip freeze`.include? 'lizard')
        puts "Installing Lizard...".blue
        `pip install --user importlib argparse`
        `pip install --user lizard`
      end
    rescue Errno::ENOENT
      @logger.error("Dependency Error: Python not installed...")
      abort "Python not installed. Please install Python and make sure it is added to your PATH.".red
    end
  end

  def ruby_dependencies
    puts "Installing metric_fu...".blue
    `gem install metric_fu`
  end

  def cpd_dependencies
    if !File.directory?(File.expand_path("~/pmd"))
      puts "Installing pmd...".green
      `git clone https://github.com/iconnor/pmd.git #{File.expand_path("~/pmd")}`
    end
  end

  def objc_dependencies
    if !File.directory?(File.expand_path("~/ocstyle"))
      puts "Installing ocstyle...".green
      `https://github.com/founderbliss/ocstyle.git #{File.expand_path("~/ocstyle")}`
    end
  end

  def perl_dependencies
    `perl -MCPAN -e 'install Perl::Critic'`
  end

  def install_dependencies
    if @languages.any? { |lang| ["JavaScript", "nodejs", "node"].include? lang }
      js_dependencies
    end
    if @languages.any? { |lang| ["PHP","Laravel","php","elgg"].include? lang }
      php_dependencies
    end
    if @languages.any? { |lang| ["Objective-C", "Objective-C++"].include? lang }
      c_dependencies
    end
    if @languages.any? { |lang| ["wordpress"].include? lang }
      wordpress_dependencies
    end
    if @languages.any? { |lang| ["Python", "django"].include? lang }
      python_dependencies
    end
    if @languages.any? { |lang| ["rails","ruby"].include? lang }
      ruby_dependencies
    end
    if @languages.any? { |lang| ["Perl"].include? lang }
      perl_dependencies
    end
    if @languages.any? { |lang| ["Objective-C", "ios"].include? lang }
      objc_dependencies
    end
    css_dependencies
    cpd_dependencies
  end
end
