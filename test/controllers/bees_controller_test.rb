require 'test_helper'

class BeesControllerTest < ActionDispatch::IntegrationTest

  def setup
      # Create a test image from a test Dockerfile
      @image_name="gopex/beekeeper_test_image:#{rand(10000)}"
      @image = Docker::Image.build_from_dir(Rails.root.join('test', 'fixtures', 'files', '.').to_path, t: @image_name)
  end

  def teardown
    # Remove all remaining bees
    DockerHelper.get_all_bees.each do |bee|
      bee.delete('force': 'true')
    end

    # Remove created image
    @image.remove(name: @image_name)
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
    assert_equal DockerHelper.get_all_bees.count, response.count
  end

  test "should get show" do
    container = @image.run
    container_id = container.json['Id']

    get "/bees/#{container_id}"
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal container_id, response['id']
  end

  test "should get not found" do
    get "/bees/1337"
    assert_response :not_found

    response = JSON.parse(@response.body)
    assert_not_nil response['exception']
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

  test "should create bee even if image was not pulled" do
    image_name_to_force_pull = 'gopex/beekeeper_test_image:latest'
    begin
      Docker::Image.remove(image_name_to_force_pull)
    rescue Docker::Error::NotFoundError
    end

    assert_raise Docker::Error::NotFoundError do
      Docker::Image.get(image_name_to_force_pull)
    end

    post '/bees', params: {
      container: {
        image: image_name_to_force_pull,
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
      container.delete(force: true)
      Docker::Image.remove(image_name_to_force_pull)
    end
  end
end
