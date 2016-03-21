require_relative 'copyright'
module Gitbase
  def checkout_commit(git_dir, commit)
    throw 'Git directory not found' unless File.exist?(git_dir)
    # cmd = get_cmd("cd #{git_dir};git reset --hard HEAD")
    cmd = "cd #{git_dir} && git reset --hard HEAD > /dev/null 2>&1"
    `#{cmd}`
    # cmd = get_cmd("cd #{git_dir};git clean -f -d")
    cmd = "cd #{git_dir} && git clean -f -d > /dev/null 2>&1"
    `#{cmd}`
    # co_cmd = get_cmd("cd #{git_dir};git checkout #{commit}")
    co_cmd = "cd #{git_dir} && git checkout #{commit}"
    stdin, stdout, stderr = Open3.popen3(co_cmd)
    @ref = nil
    while (err = stderr.gets)
      # puts err unless err.include? "Already on 'master'"
      @ref = err
      next unless err =~ /Your local changes to the following files would be overwritten by checkout/
      `#{remove_command} #{git_dir}/*`
      # cmd = get_cmd("cd #{git_dir};git checkout #{co_cmd}")
      cmd = "cd #{git_dir} && git checkout #{commit}"
      `#{cmd}`
      # cmd = get_cmd("cd #{git_dir};git reset --hard HEAD")
      cmd = "cd #{git_dir} && git reset --hard HEAD"
      `#{cmd}`
      # cmd = get_cmd("cd #{git_dir};git clean -fdx")
      cmd = "cd #{git_dir} && git clean -fdx"
      `#{cmd}`
      @ref = `#{co_cmd}`
      break
    end
  end

  def remove_open_source_files(git_dir)
    # Remove open source files
    open_source_lines = nil
    open_source_lines = `egrep -i "free software|Hamano|jQuery|BSD|GPL|GNU|MIT|Apache" #{git_dir}/* -R`
    open_source_lines = open_source_lines.encode('UTF-8', invalid: :replace, undef: :replace, replace: '').split("\n")
    open_source_lines.keep_if do |line|
      line =~ /License|Copyright/i
    end
    todo = []
    temp_start = git_dir
    open_source_lines.each do |line|
      line = line.tr('\\', '/')
      if match = /^#{git_dir}([^:]+?)\/[^\/:\s]*license|licence|readme|(.txt|.md):/i.match(line)
        # puts "license file found: #{line}"
        file_name = "#{temp_start}#{match[1]}"
        next if file_name == git_dir
        todo << ["#{remove_command} '#{file_name}/*'", file_name] if match[1]
      elsif match = /^#{temp_start}([^:]+?)\/[^\/]*manifest.xml:/i.match(line)
        # puts "manifest file found: #{line}"
        file_name = "#{temp_start}#{match[1]}"
        next if file_name == git_dir
        todo << ["#{remove_command} '#{file_name}/*'", file_name] if match[1]
      elsif match = /^#{temp_start}([^:]+?):/i.match(line)
        file_name = "#{temp_start}#{match[1]}"
        todo << ["rm '#{file_name}'", file_name] if match[1]
      end
    end
    if File.exist?(File.join(git_dir, 'NuGet.config')) && Dir.exist?(File.join(git_dir, 'packages'))
      file_name = File.join(git_dir, 'packages')
      todo << ["#{remove_command} '#{file_name}'", file_name]
    end
    todo.uniq!
    todo.each do |cmd, fn|
      `#{cmd}` if File.exist?(fn)
    end
  end

  def find_copyright(git_dir, is_demo = false)
    puts "Finding copyrights: #{git_dir}".blue
    owners = []
    egrep_cmd = Gem.win_platform? ? "\"C:/Program Files (x86)/GnuWin32/bin/egrep.exe\"" : 'egrep'
    copyright_lines = `#{egrep_cmd} -i "copyright|\(c\)|\&copy\;" #{git_dir}/* -R`
    copyright_lines = copyright_line.encode('UTF-8', invalid: :replace, undef: :replace, replace: '').split("\n")
    copyright_lines.each do |line|
      owner, file = Copyright.find_owner(line)
      next if is_demo && (file =~ /fixture/)
      owners << owner
    end
    owners = owners.compact.uniq
    puts "Found #{owners.count} owners under: #{git_dir}".green
    owners
  end

  def cloc_options
    '--yaml --quiet --skip-uniqueness --progress-rate 0'
  end

  def cloc_command
    pwd = `git rev-parse --show-toplevel`.strip
    "#{pwd}/bin/cloc"
  end

  def remove_command
    'rm -rf'
  end

  def sense_project_type(git_dir)
    # language = ''
    languages = []
    if Dir.entries(git_dir).find { |e| /\.sln$/ =~ e }
      # language = ".NET"
      languages.push('.NET')
    elsif !Dir.glob(File.join(git_dir, '**/*.rb')).empty?
      languages.push('ruby')
      if File.exist?(File.join(git_dir, 'config', 'boot.rb'))
        # language = 'rails'
        languages.push('rails')
      end
    elsif File.exist?(File.join(git_dir, 'Podfile')) || !Dir.glob(File.join(git_dir, '**/*.xcodeproj')).empty?
      # language = 'ios'
      languages.push('ios')
      languages.push('Objective-C')
    elsif File.exist?(File.join(git_dir, 'Godeps'))
      # language = 'go'
      languages.push('go')
    elsif File.directory?(File.join(git_dir, 'wp-content'))
      # language = 'wordpress'
      languages.push('wordpress')
    elsif !Dir.glob(File.join(git_dir, '**/*.php')).empty?
      if File.exist?(File.join(git_dir, 'server.php')) && file_contains("#{git_dir}/server.php", /package[ ]+Laravel/)
        languages.push('Laravel')
      elsif File.exist?(File.join(git_dir, 'index.php')) && file_contains("#{git_dir}/index.php", 'package Elgg')
        languages.push('elgg')
      else
        languages.push('php')
      end
    elsif !Dir.glob(File.join(git_dir, '*.py')).empty?
      if File.exist?(File.join(git_dir, 'manage.py'))
        if file_contains("#{git_dir}/manage.py", 'django')
          # language = 'django'
          languages.push('django')
        end
      end
      # language = 'Python'
      languages.push('Python')
    elsif File.exist?(File.join(git_dir, 'package.json'))
      # language = 'nodejs'
      languages.push('nodejs')
    elsif !Dir.glob(File.join(git_dir, '**/*.java')).empty? || File.exist?(File.join(git_dir, 'build.gradle'))
      # language = 'Java'
      languages.push('android') if File.exist?(File.join(git_dir, 'AndroidManifest.xml'))
      languages.push('Java')
    elsif !Dir.glob(File.join(git_dir, '**/*.pm')).empty? || !Dir.glob(File.join(git_dir, '**/*.pl')).empty?
      languages.push('Perl')
    end
    if languages.empty?
      cloc_lang = sense_project_type_cloc(git_dir)
      languages.push(cloc_lang) unless cloc_lang.nil?
    end
    languages
  end

  def sense_project_type_cloc(git_dir)
    # Go for most common language
    cloc = `perl #{cloc_command} #{git_dir} #{cloc_options}`
    cloc_hash = YAML.load(cloc)
    max = 0
    language = nil
    if cloc_hash
      cloc_hash.each_pair do |lang, values|
        if (max < values['code'].to_i) && (lang != 'SUM')
          language = lang
          max = values['code'].to_i
        end
      end
    end
    language
  end

  def file_contains(file_path, search_string)
    if search_string.is_a? Regexp
      File.read(file_path) =~ search_string
    else
      File.read(file_path).include?(search_string)
    end
  end

  def get_test_dirs(git_dir, test_files_match, test_dirs_match)
    regex_files = test_files_match * '|'
    regex_dirs = test_dirs_match * '|'
    "#{git_dir} --match-f='#{regex_files}' --match-d='#{regex_dirs}'"
  end

  def remove_excluded_directories(excluded_dirs, git_dir)
    excluded_dirs.each do |dir|
      next if dir =~ /\.\./
      nested_dirs = Dir.glob(File.join(git_dir, '**', dir))
      nested_dirs.each do |nd|
        `#{remove_command} #{nd}` if File.exist? nd
      end
    end
  end

  def remove_symlinks(git_dir)
    `find #{git_dir} -type l -delete`
  end

  def create_working_copy(initial_dir, destination_dir)
    @logger.info("\tCreating working copy...") if @logger
    `cp -r #{initial_dir} #{destination_dir}`
  end

  def git_dir?(dir)
    return false unless File.directory?("#{dir}/.git")
    cmd = "cd #{dir} && git rev-parse"
    cmd = "#{cmd} > /dev/null 2>&1"
    system(cmd)
  end

  def configure_branch(repo_dir)
    branches = `cd #{repo_dir} && git branch`.split("\n").map(&:strip)
    branch = branches.find { |b| b.start_with? '* ' }
    branch.sub(/\* /, '')
  end

  def git_url(dir_name)
    git_base_cmd = "cd #{dir_name} && git config --get remote.origin.url"
    url = `#{git_base_cmd}`
    if url.empty?
      svn_base_cmd = "cd #{dir_name} && git svn info | grep URL | cut -f2- -d' '"
      url = `#{svn_base_cmd}`
    end
    url.chomp
  end

  def extract_name_from_git_url(git_dir)
    begin
      return git_url(git_dir).split('/').last.gsub('.git', '')
    rescue
      return git_dir.split('/').last
    end
  end
end
