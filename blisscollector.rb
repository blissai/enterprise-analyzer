#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
require_relative 'lib/bootstrap'
include Common
task = ARGV.first
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

puts 'Configuring AWS...'.blue
$aws_client = Aws::S3::Client.new(region: 'us-east-1')
puts 'AWS configured.'.green

if task == 'collector'
  CollectorTask.new(config['TOP_LVL_DIR'], config['ORG_NAME'],
                    config['API_KEY'], config['BLISS_HOST']).execute
else
  ctasks = ConcurrentTasks.new(config)
  if task == 'stats'
    ctasks.stats
  elsif task == 'linter'
    ctasks.linter
  end
end
