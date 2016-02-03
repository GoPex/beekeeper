class ContainersController < ApplicationController
  def index
    bees = {}
    Beekeeper::DockerHelper.get_all_bees.each do |bee|
      bee_json = bee.json
      bees[bee_json['Id']] = {status: bee_json['State']['Status'],
                              address: bee_json['NetworkSettings']['Ports']}
    end
    render json: bees
  end

  def create
    permitted_params = container_params

    ports = {}
    permitted_params[:ports].each do |port|
      ports[port] = [{}]
    end

    container = Docker::Container.create(Image: permitted_params[:image],
                                         Entrypoint: permitted_params[:entrypoint],
                                         Cmd: permitted_params[:parameters],
                                         Labels: { beekeeper: "#{Beekeeper::VERSION}" },
                                         HostConfig: {
                                           PortBindings: ports
                                         })
    container.start

    container_json = container.json
    render json: {id: container.id,
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
