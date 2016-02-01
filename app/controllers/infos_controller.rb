class InfosController < ApplicationController
  def version
    render json: {version: Beekeeper::VERSION, api_version: Beekeeper::API_VERSION}
  end

  def docker_version
    render json: Docker.version
  end

  def docker
    render json: Docker.info
  end
end
