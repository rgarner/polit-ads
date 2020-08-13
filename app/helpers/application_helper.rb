module ApplicationHelper
  def timeline(values, options = {})
    render 'shared/timeline', values: values, options: options
  end

  ##
  # Primarily for Loaf/breadcrumbs, this lets us say
  #
  # breadcrumb -> { @campaign.name }, :current
  #
  # and have it always be greyed
  def current_path
    request.path
  end
end
