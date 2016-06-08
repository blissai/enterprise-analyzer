# Set of common functions used by all commands
module Common
  include Http

  def init_configuration(git_dir, api_key, repo)
    @git_dir = git_dir
    @name = repo['full_name'].split('/').last
    @organization = repo['full_name'].split('/').first
    @api_key = api_key
    @host = ENV['BLISS_HOST']
    @repo = repo
    @repo_key = @repo['repo_key']
  end

  def get_cmd(cmd)
    "(#{cmd})"
  end

  def get_directory_list(top_dir_name)
    top_dir_with_star = File.join(top_dir_name.to_s, '*')
    Dir.glob(top_dir_with_star).select { |f| File.directory?(f) && git_dir?(f) }
  end

  def save_bliss_file(top_dir_name, data)
    File.open("#{top_dir_name}/.bliss.json", 'w') do |f|
      f.write(data.to_json)
    end
  end

  def read_bliss_file(top_dir_name)
    JSON.parse(File.open("#{top_dir_name}/.bliss.json", 'r').read)
  end

  def upload_to_aws(bucket, key, content, tried = 0)
    url = "https://#{bucket}.s3.amazonaws.com/#{key}"
    @auth_headers['x-amz-acl'] = 'bucket-owner-read'
    http_multipart_put(url, content)
  end

  def todo_count(repo_key, type, tried = 0)
    count_json = http_get("#{@host}/api/gitlog/#{type}_todo_count?repo_key=#{repo_key}")
    count = count_json["#{type}_todo"].to_i
    max = 5
    return count if count > 0
    if tried < 5
      show_wait_cursor(2**tried, tried + 1, max)
      return todo_count(repo_key, type, tried + 1)
    else
      print "\n"
      return 0
    end
  end

  def show_wait_cursor(seconds, tried, max, fps = 10)
    chars = %w(| / - \\)
    delay = 1.0 / fps
    (seconds * fps).round.times do |i|
      seconds_left = seconds - (i / fps)
      print "\t(#{tried}/#{max}) No jobs found... Trying again in #{seconds_left} seconds #{chars[i % chars.length]}     \r".yellow
      sleep delay
    end
  end

  def extract_repo_key(str)
    key = /^repo_key\([^\)]*\)/.match(str)
    return [nil, str] if key.nil?
    key = key[0].gsub(/repo_key\(/, '').gsub(/\)$/, '')
    str = str.gsub(/repo_key\([^\)]*\)/, '')
    [key, str]
  end
end
