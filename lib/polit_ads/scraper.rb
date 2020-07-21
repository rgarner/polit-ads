# frozen_string_literal: true

require 'ferrum'
require 'addressable'
require 'active_record'

module PolitAds
  ##
  # Scrape them ads
  class Scraper
    LIMIT = 2000

    ACCESS_TOKEN = ENV['FB_ACCESS_TOKEN'] || raise('Set FB_ACCESS_TOKEN')

    attr_accessor :logger

    def initialize(logger: Logger.new(STDERR))
      self.logger = logger
    end

    def browser
      @browser ||= Ferrum::Browser.new
    end

    def ad_url_template
      @ad_url_template = Addressable::Template.new('https://www.facebook.com/ads/archive/render_ad/{?id,access_token}')
    end

    def ad_url(advert)
      matches = advert.ad_snapshot_url.match(/\?id=(?<id>[0-9]*)/)
      ad_url_template.expand(id: matches[:id], access_token: ACCESS_TOKEN)
    end

    def populate_urls(advert)
      browser.goto(ad_url(advert))

      last_link = browser.css('a').last
      advert.external_tracking_url = last_link.attribute('href')
      advert.external_text = last_link.inner_text

      external_tracking_url = Addressable::URI.parse(advert.external_tracking_url)
      external_url = Addressable::URI.parse(external_tracking_url.query_values&.fetch('u'))
      if external_url
        advert.external_url = external_url.to_s
        logger.info "#{advert.ad_snapshot_url}\n\t#{external_url.host}: #{external_url&.query_values}"
      else
        logger.warn "no query string, expected an l.facebook.com URL: #{external_tracking_url}"
      end

      advert.save!
    end

    def scrape!
      ActiveRecord::Base.logger = Logger.new(STDERR)
      Advert.recent.ads_of_interest.unpopulated.limit(LIMIT).each do |advert|
        populate_urls(advert)
      end
    end
  end
end