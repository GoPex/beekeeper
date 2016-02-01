class ContainersController < ApplicationController
  require 'docker'

  def create
    permitted_params = container_params

    ports = {}
    permitted_params[:ports].each do |port|
      ports[port] = [{}]
    end

    container = Docker::Container.create(Image: permitted_params[:image],
                                         Entrypoint: permitted_params[:entrypoint],
                                         Cmd: permitted_params[:parameters],
                                         HostConfig: {
                                           PortBindings: ports
                                         } )
    container.start

    container_json = container.json
    render json: {id: container_json['Id'],
                  status: container_json['State']['Status'],
                  address: container_json['NetworkSettings']['Ports']}
  end

  def destroy
    container = Docker::Container.get(params[:id])
    container.delete('force': 'true')
    render json: {id: params[:id], status: 'deleted'}
  end

  private

  def container_params
    params.require(:container).permit(:image, :entrypoint, parameters: [], ports: [])
  end
end
