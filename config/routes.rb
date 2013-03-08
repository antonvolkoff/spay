OffersTest::Application.routes.draw do
  resources :offers, only: [:new, :create]
  root to: 'offers#new'
end
