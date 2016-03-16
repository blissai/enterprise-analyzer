module Gitlogger
  include Common
  include Gitbase
  include AwsUploader

  def git_log(dir_name, limit = nil)
    start = Time.now
    log_fmt = '"%H|%P|%ai|%aN|%aE|%s"'
    cmd = "cd #{dir_name} && git log --shortstat --all --pretty=format:#{log_fmt}"
    cmd += " --max-count=#{limit}" if limit
    logs = `#{cmd}`
    puts "Gitlog took #{Time.now - start} seconds..."
    logs
  end

  def prepare_log(name, lines)
    @logger.info("\tSaving repo data to AWS Bucket...")
    key = "#{@org_name}_#{name}_git.log"
    upload_to_aws('bliss-collector-files', key, lines)
    key
  end

  def collect_logs(dir_name, name, branch, limit = nil)
    checkout_commit(dir_name, branch)
    @logger.info("\tGetting gitlog for #{name}")
    git_log(dir_name, limit)
  end
end
