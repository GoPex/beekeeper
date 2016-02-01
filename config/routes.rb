Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/', defaults: { format: :json }, constraints: {format: :json } do
    resource :info, only: [] do
      collection do
        get 'version'
        get 'docker_version'
        get 'docker'
      end
    end

    resources :containers, only: [:create, :destroy]
  end
end
