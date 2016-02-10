require 'test_helper'

class BeesControllerTest < ActionDispatch::IntegrationTest

  def setup
    # Create a test image from a test Dockerfile
    @image = Docker::Image.build_from_dir(Rails.root.join('test', 'fixtures', 'files', '.').to_path, t: "gopex/beekeeper_test_image:#{rand(10000)}")
    @image_name = @image.json['RepoTags'].first
  end

  def teardown
    # Remove all remaining bees
    Beekeeper::DockerHelper.get_all_bees.each do |container|
      container.delete('force': 'true')
    end

    # Remove created image
    @image.remove(force: true)
    @image = nil
  end

  test "should get index" do
    3.times do
      @image.run
    end

    get "/bees"
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal 3, response.count
    assert_equal Beekeeper::DockerHelper.get_all_bees.count, response.count
  end

  test "should get show" do
    container = @image.run
    container_id = container.json['Id']

    get "/bees/#{container_id}"
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal container_id, response['id']
  end

  test "should create bee" do
    post '/bees', params: {
      container: {
        image: "#{@image_name}",
        entrypoint: 'tail',
        parameters: ['-f', '/dev/null']
      }
    }
    assert_response :success

    response = JSON.parse(@response.body)
    assert_not_nil response['id']
    assert_not_nil response['status']
    assert_nil response['addresses']['3000/tcp']

    assert_nothing_raised do
      container = Docker::Container.get(response['id'])
      assert container.json['State']['Status'] == response['status']
    end
  end

  test "should create bee with an opened port" do
    post '/bees', params: {
      container: {
        image: "#{@image_name}",
        entrypoint: 'tail',
        parameters: ['-f', '/dev/null'],
        ports: ['3000/tcp']
      }
    }
    assert_response :success

    response = JSON.parse(@response.body)
    assert_not_nil response['id']
    assert_not_nil response['status']
    assert_not_nil response['addresses']['3000/tcp']

    assert_nothing_raised do
      container = Docker::Container.get(response['id'])
      assert container.json['State']['Status'] == response['status']
    end
  end

  test "should destroy bee" do
    container = @image.run
    container_id = container.json['Id']

    delete "/bees/#{container_id}"
    assert_response :success

    response = JSON.parse(@response.body)
    assert_not_nil response['id']
    assert_not_nil response['status']

    assert_raise Docker::Error::NotFoundError do
      Docker::Container.get(container_id)
    end
  end
end
