Rails.application.routes.draw do
  resource :auth, only: [:show, :create, :destroy], controller: :auth
  resource :auth_verification, only: [:show, :create], controller: :auth_verification
  root "home#index"
end

