require 'test_helper'

class InfosControllerTest < ActionDispatch::IntegrationTest
  test "shoud get ping" do
    get '/info/ping'
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal 'OK', response['pong']
  end

  test "shoud get status" do
    get '/info/status'
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal 'OK', response['status']
    assert_equal Docker.ping, response['docker_host_status']
  end

  test "should get version" do
    get '/info/version'
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal BeekeeperHelper::VERSION, response['version']
    assert_equal BeekeeperHelper::API_VERSION, response['api_version']
  end

  test "should get docker version" do
    get '/info/docker_version'
    assert_response :success

    response = JSON.parse(@response.body)
    refute_nil response['Version']
    refute_nil response['ApiVersion']
  end

  test "should get docker info" do
    get '/info/docker'
    assert_response :success

    response = JSON.parse(@response.body)
    refute_nil response['ServerVersion']
  end
end
