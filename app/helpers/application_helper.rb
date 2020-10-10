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

  ##
  # A bootstrap nav item with auto active class
  def nav_item(text, path, options = {}, &block)
    tag.li class: 'nav-item' do
      options[:class] ||= ''
      options[:class] = options[:class] + " nav-link #{'active' if request.path == path}"
      if block
        link_to path, options, &block
      else
        link_to text, path, options
      end
    end
  end

  def font_awesome_icon_for(wants_key)
    fa_class = {
      'money' => 'fa-money-bill-wave',
      'data' => 'fa-table',
      'you_to_buy' => 'fa-credit-card',
      'you_to_vote' => 'fa-vote-yea',
      'you_to_volunteer' => 'fa-hands-helping',
      'you_to_attend' => 'fa-calendar-day',
      'to_persuade_you' => 'fa-hands',
      'you_to_be_deterred' => 'fa-user-alt-slash'
    }[wants_key]

    tag.i class: "fas #{wants_key.dasherize} #{fa_class}"
  end

  def markdown_to_html(markdown)
    Kramdown::Document.new(markdown).to_html.html_safe
  end

  def round_dollars(value)
    number_to_currency(value, precision: 0)
  end

  def full_date(date)
    date.in_time_zone('EST').strftime('%d %B %Y, %H:%M:%S EST')
  end

  def linefeed_to_br(text)
    return nil if text.nil?

    text.gsub(/\n/, '<br>').html_safe
  end
end
