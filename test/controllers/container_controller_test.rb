require 'test_helper'

class ContainerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    post '/container/start', params: { container: { image_name: 'gopex/ubuntu', command_parameter: 'a list of awesome command to execute', conf: {port: '3232'} } }
    assert_response :success

    response = JSON.parse(@response.body)
    puts response
  end
end
