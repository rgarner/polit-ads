class HostsController < ApplicationController
  def index
    @hosts = Host.with_ad_counts
  end

  def adverts
    @host = Host.find(params[:host_id])
    @adverts = @host.adverts.page(params[:page])
  end
end
