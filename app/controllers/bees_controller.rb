class BeesController < ApplicationController
  def index
    bees = {}
    Beekeeper::DockerHelper.get_all_bees.each do |bee|
      bee_json = bee.json
      bee_addresses = parse_addresses(bee_json)
      bees[bee_json['Id']] = {status: bee_json['State']['Status'],
                              addresses: bee_addresses}
    end
    render json: bees
  end

  def create
    permitted_params = container_params

    ports = {}
    permitted_params.fetch(:ports, {}).each do |port|
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
    container_addresses = parse_addresses(container_json)

    render json: {id: container.id,
                  status: container_json['State']['Status'],
                  addresses: container_addresses}
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

  def parse_addresses(container_json)
    ports = container_json['NetworkSettings']['Ports']
    container_addresses = {}
    ports.each do |port_requested, port_exposed|
      if port_exposed.is_a?(NilClass)
        container_addresses["#{port_requested}"] = nil
      else
        container_addresses["#{port_requested}"] = "#{port_exposed[0]['HostIp']}:#{port_exposed[0]['HostPort']}"
      end
    end
    container_addresses
  end
end
