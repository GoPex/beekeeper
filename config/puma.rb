# puma.rb

# Number of concurrent processes
workers Integer(ENV['BEEKEEPER_WEB_CONCURRENCY'] || 2)

# Number of thread a process can spawn
threads_count = Integer(ENV['BEEKEEPER_MAX_THREADS'] || 10)
threads threads_count, threads_count

# Set listening address
bind ENV['BEEKEEPER_BIND'] || 'unix:///var/run/puma.sock'
# Set port
port ENV['BEEKEEPER_PORT'] || 3000

# Set environment
environment ENV['RACK_ENV'] || 'development'

# Pre load the application before forking it, reducing the startup time of these process
preload_app!

# As we pre loaded the application, we mus establish database connection ourselves
# Commented out for the moment as we have no persistency
#on_worker_boot do
  #ActiveRecord::Base.establish_connection
#end
