Rails.application.routes.draw do
  # Root route is just a ping
  root 'infos#ping'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/', defaults: { format: :json }, constraints: {format: :json } do
    resource :info, only: [] do
      collection do
        get 'ping'
        get 'status'
        get 'version'
        get 'docker_version'
        get 'docker'
      end
    end

    resources :bees, only: [:index, :show, :create, :destroy]
  end
end
