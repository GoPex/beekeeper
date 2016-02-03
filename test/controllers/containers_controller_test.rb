require 'test_helper'

class ContainersControllerTest < ActionDispatch::IntegrationTest

  def setup
    # Create a test image from a test Dockerfile
    @image = Docker::Image.build_from_dir(Rails.root.join('test', 'fixtures', 'files', '.').to_path, t: 'gopex/beekeeper_test_image:0.1.0')
  end

  def teardown
    # Remove all remaining bees
    Beekeeper::DockerHelper.get_all_bees.each do |container|
      container.delete('force': 'true')
    end

    # Remove created image
    @image.remove(force: true)
  end

  test "should get index" do
    3.times do
      @image.run
    end

    get "/containers"
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal 3, response.count
    assert_equal Beekeeper::DockerHelper.get_all_bees.count, response.count
  end

  test "should create container" do
    post '/containers', params: {
      container: {
        image: 'docker-registry.gopex.be:5000/gopex/beewolf:0.1.0',
        entrypoint: 'tail',
        parameters: ['-f', '/dev/null'],
        ports: ['3000/tcp']
      }
    }
    assert_response :success

    response = JSON.parse(@response.body)
    assert_not_nil response['id']
    assert_not_nil response['status']
    assert_not_nil response['address']

    assert_nothing_raised do
      container = Docker::Container.get(response['id'])
      assert container.json['State']['Status'] == response['status']
    end
  end

  test "should destroy container" do
    container = @image.run
    container_id = container.json['Id']

    delete "/containers/#{container_id}"
    assert_response :success

    response = JSON.parse(@response.body)
    assert_not_nil response['id']
    assert_not_nil response['status']

    assert_raise Docker::Error::NotFoundError do
      Docker::Container.get(container_id)
    end
  end
end
