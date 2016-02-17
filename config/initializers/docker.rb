# Configure docker connection
Docker.url = ENV.fetch('DOCKER_HOST_URL') { 'unix:///var/run/docker.sock' }
Docker.logger = Logger.new(STDOUT) if ENV.fetch('DOCKER_DEBUG') { false }
