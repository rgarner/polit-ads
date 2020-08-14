module AdCodesHelper
  def new_ad_code?(ad_code, days = 2)
    threshold = Date.today - days.to_i
    ad_code.first_used > threshold
  end

  def nav_link(action)
    bootstrap_class = "nav-link #{action.to_s == params[:action].to_s ? 'active' : ''}"

    case action
    when :show
      link_to 'Timeline', campaign_ad_code_path(@campaign, id: @ad_code.index), class: bootstrap_class
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
end
