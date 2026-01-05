Furia::Engine.routes.draw do
  resources :samples, only: %i[index show destroy]
  root to: redirect("samples")
end
