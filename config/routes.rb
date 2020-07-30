Rails.application.routes.draw do
  resources :adverts, only: :show
  get 'adverts/by_utm_value/:utm_value', to: 'adverts#by_utm_value', as: :adverts_by_utm_value
  resources :utm_campaign_values, only: %i[show index]
end
