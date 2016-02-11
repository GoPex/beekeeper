class ApplicationController < ActionController::API
  before_action :api_authenticate

  private

  def api_authenticate
    requester_id = ApiAuth.access_id(request)

    @secret_key = ENV["#{requester_id}_API_KEY"]
    if not @secret_key
      logger.warn "No secret key found for requester id '#{requester_id}'. Unauthorized !"
      head(:unauthorized)
    elsif not ApiAuth.authentic?(request, @secret_key)
      logger.warn "Request not considered as authentic for requester id '#{requester_id}'. Unauthorized !"
      head(:unauthorized)
    end
  end
end
