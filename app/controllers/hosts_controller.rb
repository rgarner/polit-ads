class HostsController < ApplicationController
  breadcrumb 'Hosts', :hosts_path, match: :exclusive

  def index
    @hosts = Host.with_ad_counts
    @host_ad_counts = Host.summary_graph_data
  end

  def adverts
    @host = Host.find(params[:host_id])
    @adverts = @host.adverts.order(ad_creation_time: :desc).page(params[:page])

    breadcrumb "#{@host.hostname} / Adverts", request.path
  end
end
