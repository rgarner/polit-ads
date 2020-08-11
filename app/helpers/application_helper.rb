module ApplicationHelper
  def timeline(values, options = {})
    render 'shared/timeline', values: values, options: options
  end
end
