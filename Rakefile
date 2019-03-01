Encoding.default_external = 'UTF-8'

Dir.glob(File.join('**', '*.rb')) { |f| require_relative f }

desc 'Run the script'
task :run do
  # make sure there are empty rake tasks for all input args
  ARGV.each { |a| task a.to_sym {} }
  in_file = ARGV.drop(1).first
  HashCode.new(in_file).run
end
