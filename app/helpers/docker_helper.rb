class DockerHelper
  def self.get_all_bees
    # Gel all containers defined with a label named beekeeper
    Docker::Container.all(all: 1, filters: { label: [ "beekeeper" ] }.to_json)
  end

  def self.create(image, entrypoint, parameters, ports)
    # Create a container using parameters and a label named beekeeper
    Docker::Container.create(Image: image,
                             Entrypoint: entrypoint,
                             Cmd: parameters,
                             Labels: { beekeeper: "#{BeekeeperHelper::VERSION}" },
                             HostConfig: {
                              PortBindings: ports
                             })
  end

  def self.run(image, entrypoint, parameters, ports)
    begin
      # Create the container
      bee = self.create(image, entrypoint, parameters, ports)
    rescue Docker::Error::NotFoundError
      # The image doesn't exist on the host, pull it explicitly before creating the container
      Docker::Image.create(fromImage: image)
      bee = self.create(image, entrypoint, parameters, ports)
    end

    # Start the container
    bee.start

    # Return the running bee
    bee
  end
end
