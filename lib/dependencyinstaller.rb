class DependencyInstaller
  include Gitbase
  include Common

  def initialize(top_lvl_dir)
    @logger = BlissLogger.new("Dependencies-#{Time.now.strftime("%d-%m-%y-T%H-%M")}")
    @top_lvl_dir = top_lvl_dir
    @dirs_list = get_directory_list(@top_lvl_dir)
    # Determines languages of all the projects
    @languages = determine_languages

    # Determines if windows
    @platform = Gem.win_platform? ? 'Windows' : @platform = 'Unix'

    # Install choco if Windows
    install_chocolatey if windows?

    # Determines package manager to use
    if windows?
      @pkgmgr = 'choco -y'
    else
      # Is Debian based?
      if `command -v apt-get`.present?
        @pkgmgr = 'apt-get'
        # Is RPM?
      elsif `command -v yum`.present?
        @pkgmgr = 'yum -y'
        # Is OSX?
      elsif `command -v brew`
        @pkgmgr = 'brew'
      end
    end
  end

  # Returns if platform is windows
  def windows?
    @platform == 'Windows'
  end

  # Determines which package manager to use for install
  def pkgmgr
    @pkgmgr
  end

  def run
    puts 'Installing dependencies...'.blue
    # Install required languages and package managers
    # install_perl
    # install_npm if ["JavaScript", "nodejs", "node"].any? { |lang| @languages.include? lang }
    # install_php if ["PHP", "php", "wordpress"].any? { |lang| @languages.include? lang }
    # # Also install Python and pip for C langs as is used to download linters
    # install_python if ["Python", "python", "django", "Objective-C", "Objective-C++"].any? { |lang| @languages.include? lang }

    # Install linters
    LintInstaller.new(@languages, @logger).run
    @logger.save_log
  end

  # Installs the Chocolatey Package Manager
  def install_chocolatey
    unless command_exists? 'choco'
      puts 'Installing Chocolatey...'
      `@powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin`
    end
  end

  # Installs nodejs and npm
  def install_npm
    unless command_exists? "node -v"
      puts "Installing node and npm..."
      if windows?
        command = 'choco install nodejs'
      else
        command = "#{pkgmgr} install nodejs npm"
        command += ' --enablerepo=epel' if pkgmgr.include? 'yum'
      end
      `#{command}`
    end
  end

  # Install PHP composer
  def install_php
    # Install PHP if not present
    unless command_exists? 'php -v'
      puts 'Installing PHP...'
      `#{pkgmgr} install php`
    end

    # Install composer if not present
    unless command_exists? 'composer -v'
      puts 'Installing Composer...'
      `#{pkgmgr} install composer`
    end
  end

  # Installs perl (should be only for windows)
  def install_perl
    unless command_exists? 'perl -v'
      puts 'Installing Perl...'
      `#{pkgmgr} install strawberryperl`
    end
  end

  # Installs python (should be only for windows)
  def install_python
    unless command_exists? 'python -V'
      puts 'Installing python'
      `#{pkgmgr} install python`
    end
  end

  def command_exists?(command)
    if windows?
      !`#{command}`.nil?
    else
      begin
        `#{command}`
        true
      rescue Exception => e
        puts "#{command.split(' ')[0]} not detected..."
        false
      end
    end
  end

  # Determine languages/frameworks used in the repositories
  def determine_languages
    langs = []
    @dirs_list.each do |git_dir|
      project_types = sense_project_type(git_dir)
      langs = (langs << project_types).flatten!
    end
    langs.uniq
  end
end
