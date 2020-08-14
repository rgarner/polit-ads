class ApplicationController < ActionController::Base
  breadcrumb 'Campaigns', :campaigns_path, match: :exclusive
end
