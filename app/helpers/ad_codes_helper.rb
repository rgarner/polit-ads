module AdCodesHelper
  def new_ad_code?(ad_code, days = 2)
    threshold = Date.today - days.to_i
    ad_code.first_used > threshold
  end

  def nav_link(action)
    bootstrap_class = "nav-link #{action.to_s == params[:action].to_s ? 'active' : ''}"

    case action
    when :show
      link_to 'Values', campaign_ad_code_path(@campaign, id: @ad_code.index), class: bootstrap_class
    when :timeline
      link_to 'Timeline', campaign_ad_code_timeline_path(@campaign, ad_code_id: @ad_code.index), class: bootstrap_class
    when :against
      link_to 'Show against', '#',
              class: bootstrap_class + ' dropdown-toggle',
              data: { toggle: 'dropdown' },
              role: 'button',
              aria: { haspopup: 'true', expanded: 'false' }
    when :hosts
      link_to 'Hosts', campaign_ad_code_hosts_path(@campaign, ad_code_id: @ad_code.index), class: bootstrap_class
    else
      raise ArgumentError("#{action} not a tab")
    end
  end

  def timeline_ranges
    {
      all_time: Date.new(2020, 5, 1),
      last_30_days: 30.days.ago.to_date,
      last_7_days: 7.days.ago.to_date
    }
  end

  def timeline_range_links
    tag.ul class: 'nav nav-pills' do
      timeline_ranges.map do |label, start_date|
        active = params[:range] == label.to_s || params[:range].nil? && label == :last_30_days
        tag.li class: 'nav-item' do
          link_to label.to_s.titleize,
            request.query_parameters.merge(start: start_date.iso8601, range: label),
                  class: "nav-link #{'active' if active }"
        end
      end.join.html_safe
    end
  end
end
