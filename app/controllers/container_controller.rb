class ContainerController < ApplicationController
  require 'docker'

  def start
    container = Docker::Container.create('Cmd' => ['ls'], 'Image' => 'gopex/ubuntu:14.04')
    render json: {container_id: container.json['Id']}
  end

  def stop
    render json: params
  end

  private

  def container_params
    params.require(:container).permit(:image_name, :command_parameter, conf: [:port])
  end
end
