module Beekeeper
  class DockerHelper
    def self.get_all_bees
      Docker::Container.all(all: 1, filters: { label: [ "beekeeper" ] }.to_json)
    end
  end
end
