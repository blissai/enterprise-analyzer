module Gitlogger
  include Common
  include Gitbase

  def git_log(dir_name, limit = nil)
    log_fmt = '"%H|%P|%ai|%aN|%aE|%s"'
    cmd = "cd #{dir_name} && git log --numstat --shortstat --all --pretty=format:#{log_fmt}"
    cmd += " --max-count=#{limit}" if limit
    logs = `#{cmd}`
    logs
  end

  def prepare_log(name, lines)
    key = "#{@org_name}_#{name}_git.log"
    upload_to_aws('bliss-collector-files', key, lines)
    key
  end

  def collect_logs(dir_name, branch = nil, limit = nil)
    checkout_commit(dir_name, branch) if branch
    git_log(dir_name, limit)
  end

  def save_git_log(name, lines, repo_key)
    s3_object_key = prepare_log(name, lines)
    http_post("#{@host}/api/gitlog", repo_key: repo_key,
                                     object_key: s3_object_key,
                                     bucket: 'bliss-collector-files')
  end
end
