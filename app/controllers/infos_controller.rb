class InfosController < ApplicationController
  def version
    render json: {version: BeekeeperHelper::VERSION, api_version: BeekeeperHelper::API_VERSION}
  end

  def docker_version
    render json: Docker.version
  end

  def docker
    render json: Docker.info
  end
end
