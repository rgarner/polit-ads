Rails.application.routes.draw do
  resources :campaigns, only: :index do
    resources :ad_codes, only: %i[show index] do
      get 'against/:other_index', to: 'ad_codes#against', as: :against
    end
  end

  resources :adverts, only: %i[show index]

  resources :utm_campaign_values, only: %i[show index] do
    get 'against/:other_id', to: 'utm_campaign_values#against', as: :against
    get 'between'
    get 'hosts'
  end

  resources :hosts, only: :index do
    get 'adverts'
  end
end
