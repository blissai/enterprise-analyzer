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
configure_http
loop do
  collector_result = CollectorTask.new(config).execute
  new_repos = collector_result['new_repos']

  ctasks = ConcurrentTasks.new(config)

  continue_stats = collector_result['stats_todo'] > 0
  ctasks.stats if continue_stats

  continue_linters = collector_result['linters_todo'] > 0
  ctasks.linter if continue_linters

  break unless continue_stats || continue_linters
end
