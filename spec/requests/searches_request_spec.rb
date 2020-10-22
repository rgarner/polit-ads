require 'rails_helper'

RSpec.describe "Searches", type: :request do
  it 'redirects to adverts with q=term' do
    post searches_path, params: { q: 'term' }

    expect(response).to redirect_to(adverts_path(q: 'term'))
  end
end
