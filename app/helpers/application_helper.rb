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

  def markdown_to_html(markdown)
    Kramdown::Document.new(markdown).to_html.html_safe
  end

  def round_dollars(value)
    number_to_currency(value, precision: 0)
  end
end
