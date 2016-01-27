#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
require_relative 'lib/bootstrap'
include Common

config = {
  'TOP_LVL_DIR' => ENV['TOP_LVL_DIR'],
  'ORG_NAME' => ENV['ORG_NAME'],
  'API_KEY' => ENV['API_KEY'],
  'BLISS_HOST' => ENV['BLISS_HOST']
}

@top_level_dir = config['TOP_LVL_DIR']
@org_name = config['ORG_NAME']
@api_key = config['API_KEY']
@host = config['BLISS_HOST']
@dirs_list = get_directory_list(@top_level_dir)
configure_http
loop do
  collector_result = CollectorTask.new(config).execute
  new_repos = collector_result['new_repos']

  ctasks = ConcurrentTasks.new(config, new_repos)

  continue_stats = collector_result['stats_todo'] > 0
  if continue_stats
    puts 'Waiting 60 seconds before running Stats task...'.green
    sleep(60)
    ctasks.stats
  end

  continue_linters = collector_result['linters_todo'] > 0
  if continue_linters
    puts 'Waiting 60 seconds before running Linter task...'.green
    sleep(60)
    ctasks.linter
  end
  break unless continue_stats || continue_linters
end
