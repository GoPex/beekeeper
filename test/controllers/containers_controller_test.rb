require 'test_helper'

class ContainersControllerTest < ActionDispatch::IntegrationTest
  require 'docker'

  def teardown
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
    assert response['id']
    assert response['status']
    assert response['address']

    assert_nothing_raised do
      container = Docker::Container.get(response['id'])
      assert container.json['State']['Status'] == response['status']
      container.delete('force': 'true')
    end
  end

  test "should destroy container" do
    container = Docker::Container.create('Image': 'gopex/ubuntu:14.04',
                                         'Entrypoint': 'tail',
                                         'Cmd': ['-f', '/dev/null'])
    container.start
    container_id = container.json['Id']

    delete "/containers/#{container_id}"
    assert_response :success

    response = JSON.parse(@response.body)
    assert response['id']
    assert response['status']

    assert_raise Docker::Error::NotFoundError do
      Docker::Container.get(container_id)
    end
  end
end
