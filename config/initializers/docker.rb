# Configure docker connection
Docker.url = ENV['DOCKER_HOST_URL'] || 'unix:///var/run/docker.sock'
Docker.logger = Logger.new(STDOUT) if ENV['DOCKER_DEBUG']
