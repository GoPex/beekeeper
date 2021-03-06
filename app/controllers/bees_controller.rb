class BeesController < ApplicationController
  rescue_from Docker::Error::NotFoundError, with: :bee_not_found

  def index
    bees = {}
    DockerHelper.get_all_bees.each do |bee|
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

    bee = DockerHelper.run(permitted_params[:image],
                           registry: permitted_params[:registry],
                           entrypoint: permitted_params[:entrypoint],
                           parameters: permitted_params[:parameters],
                           ports: ports)
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
    params.require(:container).permit(:image, :registry, :entrypoint, parameters: [], ports: [])
  end

  def parse_addresses(bee_json)
    ports = bee_json['NetworkSettings']['Ports']
    bee_addresses = {}

    ports.each do |port_requested, port_exposed|
      if port_exposed.is_a?(NilClass)
        bee_addresses["#{port_requested}"] = nil
      else
        docker_host_public_url = ENV.fetch('DOCKER_HOST_PUBLIC_URL') { ENV.fetch('DOCKER_HOST_URL') { '127.0.0.1'  } }
        bee_addresses["#{port_requested}"] = "#{docker_host_public_url}:#{port_exposed[0]['HostPort']}"
      end
    end
    bee_addresses
  end

  private

  def bee_not_found(error)
    render json: {exception: error.message}, status: :not_found
  end
end
