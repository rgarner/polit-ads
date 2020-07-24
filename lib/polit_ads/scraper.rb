# frozen_string_literal: true

require 'ferrum'
require 'addressable'
require 'active_record'
require 'concurrent'
require 'benchmark'

module PolitAds
  ##
  # Scrape them ads
  class Scraper
    LIMIT   = 1000
    THREADS = 3

    attr_accessor :logger

    def initialize(logger: Logger.new(STDERR))
      self.logger = logger
      ActiveRecord::Base.logger = logger
    end

    def run!
      time = Benchmark.measure do
        ads_to_scrape.each { |advert| scrape(advert) }

        pool.shutdown
        pool.wait_for_termination
      end

      logger.info "#{scrape_count.value} scraped in #{time.real.round(2)}s"
    end

    private

    def access_token
      ENV['FB_ACCESS_TOKEN'] || raise('Set FB_ACCESS_TOKEN')
    end

    def browser
      @browser ||= Ferrum::Browser.new
    end

    def ad_url_template
      @ad_url_template = Addressable::Template.new('https://www.facebook.com/ads/archive/render_ad/{?id,access_token}')
    end

    def ad_url(advert)
      matches = advert.ad_snapshot_url.match(/\?id=(?<id>[0-9]*)/)
      ad_url_template.expand(id: matches[:id], access_token: access_token)
    end

    def pool
      @pool ||= Concurrent::FixedThreadPool.new(THREADS)
    end

    def populate_urls(page, advert)
      page.goto(ad_url(advert))

      last_link = page.css('a').last
      advert.external_tracking_url = last_link.attribute('href')
      advert.external_text = last_link.inner_text

      external_tracking_url = Addressable::URI.parse(advert.external_tracking_url)
      external_url          = Addressable::URI.parse(external_tracking_url.query_values&.fetch('u'))

      advert.external_url = if external_url
                              logger.info "#{advert.ad_snapshot_url}\n\t#{external_url.host}: #{external_url&.query_values}"
                              external_url.to_s
                            else
                              logger.warn "no query string, expected an l.facebook.com URL: #{external_tracking_url}"
                              '#no-external-url'
                            end
    end

    def scrape(advert)
      pool.post do
        context = browser.contexts.create
        page = context.create_page

        populate_urls(page, advert)

        advert.save!
        scrape_count.increment

        context.dispose
      end
    end

    def scrape_count
      @scrape_count ||= Concurrent::AtomicFixnum.new(0)
    end

    def ads_to_scrape
      Advert.recent.ads_of_interest.unpopulated.limit(LIMIT)
    end
  end
end