Rails.application.routes.draw do
  get 'adverts/with_utm_values'
  resources :adverts, only: :show
  get 'adverts/by_utm_value/:utm_value', to: 'adverts#by_utm_value', as: :adverts_by_utm_value
  resources :utm_campaign_values, only: %i[show index] do
    get 'against/:other_id', to: 'utm_campaign_values#against'
  end
end
