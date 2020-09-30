Rails.application.routes.draw do
  root to: 'campaigns#index'

  resources :campaigns, only: :index do
    resources :ad_codes, only: %i[show index] do
      get 'against/:other_index', to: 'ad_codes#against', as: :against
      get 'hosts'
      get 'timeline'

      resources :values, only: :show
    end
  end

  get '/adverts/decode-a-link'
  resources :adverts, only: %i[show index]

  resources :decodings, only: %i[create show]

  ##
  # Redirects; this once only did one campaign - Trump's, and now
  # we must preserve URLs in spreadsheets and so on.
  get '/utm_campaign_values', to: redirect('/campaigns/trump/ad_codes')
  get '/utm_campaign_values/:id', to: redirect('/campaigns/trump/ad_codes/%{id}')
  # Between is now default view, or timeline, on ad_codes. Use path: to preserve query string
  get '/utm_campaign_values/:id/between', to: redirect(path: '/campaigns/trump/ad_codes/%{id}')
  get '/utm_campaign_values/:id/against/:other_id', to: redirect('/campaigns/trump/ad_codes/%{id}/against/%{other_id}/')
  get '/utm_campaign_values/:id/hosts', to: redirect('/campaigns/trump/ad_codes/%{id}/hosts')

  resources :hosts, only: :index do
    get 'adverts'
  end
end
