require 'test_helper'

class InfosControllerTest < ActionDispatch::IntegrationTest
  test "should get version" do
    get '/info/version'
    assert_response :success

    response = JSON.parse(@response.body)
    assert response['version']
    assert response['api_version']
  end

  test "should get docker version" do
    get '/info/docker_version'
    assert_response :success

    response = JSON.parse(@response.body)
    assert response['Version']
    assert response['ApiVersion']
  end
  
  test "should get docker info" do
    get '/info/docker'
    assert_response :success

    response = JSON.parse(@response.body)
    assert response['ServerVersion']
  end
end
