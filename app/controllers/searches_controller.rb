class SearchesController < ApplicationController
  def new; end

  def create
    redirect_to adverts_path(q: params[:q])
  end
end
