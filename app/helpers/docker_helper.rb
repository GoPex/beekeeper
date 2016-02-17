class DockerHelper
  def self.get_all_bees
    # Gel all containers defined with a label named beekeeper
    Docker::Container.all(all: 1, filters: { label: [ "beekeeper" ] }.to_json)
  end

  def self.create(image, registry: nil, entrypoint: nil, parameters: nil, ports: nil)
    # Create a container using parameters and a label named beekeeper
    Docker::Container.create(Image: self.image_full_tag(image, registry),
                             Entrypoint: entrypoint,
                             Cmd: parameters,
                             Labels: { beekeeper: "#{BeekeeperHelper::VERSION}" },
                             HostConfig: {
                              PortBindings: ports
                             })
  end

  def self.pull(image, registry: nil)
    creds = nil
    if registry
      creds = {username: 'beekeeper', password: ENV.fetch('BEEKEEPER_REGISTRY_PASSWORD') { '' }, email: 'beekeeper@gopex.be', serveraddress: registry}
    end
    Docker::Image.create({fromImage: self.image_full_tag(image, registry)}, creds)
  end

  def self.run(image, registry: nil, entrypoint: nil, parameters: nil, ports: nil)
    begin
      # Create the container
      bee = self.create(image, registry: registry, entrypoint: entrypoint, parameters: parameters, ports: ports)
    rescue Docker::Error::NotFoundError
      # The image doesn't exist on the host, pull it explicitly before creating the container
      self.pull(image, registry: registry)
      bee = self.create(image, registry: registry, entrypoint: entrypoint, parameters: parameters, ports: ports)
    end

    # Start the container
    bee.start

    # Return the running bee
    bee
  end

  private

  def self.image_full_tag(image, registry)
    if registry
      "#{registry}/#{image}"
    else
      image
    end
  end
end
