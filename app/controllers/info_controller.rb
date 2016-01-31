class InfoController < ApplicationController
  def version
    render json: {version: Beewolf::VERSION, api_version: Beewolf::API_VERSION}
  end

  def docker_version
    render json: Docker.version
  end

  def docker_info
    render json: Docker.info
  end
end
