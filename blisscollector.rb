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
@bliss_host = config['BLISS_HOST']
@dirs_list = get_directory_list(@top_level_dir)
configure_http
loop do
  new_repos = CollectorTask.new(config).execute

  ctasks = ConcurrentTasks.new(config, new_repos)
  puts 'Waiting 60 seconds before running Stats task...'.green
  sleep(60)

  continue_stats = stats_todo_count > 0
  ctasks.stats if continue_stats
  puts 'Waiting 60 seconds before running Linter task...'.green
  sleep(60)
  continue_linters = linters_todo_count > 0
  ctasks.linter if continue_linters
  break unless continue_stats || continue_linters
end
