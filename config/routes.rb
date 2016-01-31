Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/', defaults: { format: :json }, constraints: {format: :json } do
    get 'info/version', to: 'info#version'
    get 'info/docker_version', to: 'info#docker_version'
    get 'info/docker_info', to: 'info#docker_info'

    post 'container/start', to: 'container#start'
    post 'container/stop/:id', to: 'container#stop'
  end
end
