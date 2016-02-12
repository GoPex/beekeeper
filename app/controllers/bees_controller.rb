class BeesController < ApplicationController
  rescue_from Docker::Error::NotFoundError, with: :bee_not_found

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

  def show
    bee = Docker::Container.get(params[:id])
    bee_json = bee.json
    bee_addresses = parse_addresses(bee_json)

    render json: {id: params[:id],
                  status: bee_json['State']['Status'],
                  addresses: bee_addresses}
  end

  def create
    permitted_params = container_params

    ports = {}
    permitted_params.fetch(:ports, {}).each do |port|
      ports[port] = [{}]
    end

    bee = Docker::Container.create(Image: permitted_params[:image],
                                   Entrypoint: permitted_params[:entrypoint],
                                   Cmd: permitted_params[:parameters],
                                   Labels: { beekeeper: "#{Beekeeper::VERSION}" },
                                   HostConfig: {
                                    PortBindings: ports
                                   })
    bee.start

    bee_json = bee.json
    bee_addresses = parse_addresses(bee_json)

    render json: {id: bee.id,
                  status: bee_json['State']['Status'],
                  addresses: bee_addresses}
  end

  def destroy
    bee = Docker::Container.get(params[:id])
    bee.delete('force': 'true')

    render json: {id: params[:id], status: 'deleted'}
  end

  private

  def container_params
    params.require(:container).permit(:image, :entrypoint, parameters: [], ports: [])
  end

  def parse_addresses(bee_json)
    ports = bee_json['NetworkSettings']['Ports']
    bee_addresses = {}
    ports.each do |port_requested, port_exposed|
      if port_exposed.is_a?(NilClass)
        bee_addresses["#{port_requested}"] = nil
      else
        bee_addresses["#{port_requested}"] = "#{port_exposed[0]['HostIp']}:#{port_exposed[0]['HostPort']}"
      end
    end
    bee_addresses
  end

  private

  def bee_not_found(error)
    render json: {exception: error.message}, status: :not_found
  end
end
