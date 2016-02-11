# puma.rb

# Number of thread a process can spawn
threads_count = ENV.fetch('MAX_THREADS') { 10 }.to_i
threads threads_count, threads_count

# Set listening address
bind ENV.fetch('BIND') { 'tcp://0.0.0.0:3000' }

# Set environment
environment ENV.fetch('RAILS_ENV') { 'development' }

# Number of concurrent processes
workers ENV.fetch('CONCURRENCY') { 2 }.to_i

# Pre load the application before forking it, reducing the startup time of these process
preload_app!

# As we pre loaded the application, we mus establish database connection ourselves
# Commented out for the moment as we have no persistency
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
