# frozen_string_literal: true

module PolitAds
  ##
  # Fill in hosts table from external_urls in adverts
  # and point adverts at those hosts
  class HostsPopulator
    INSERT_HOSTS = <<~POSTGRESQL
      INSERT INTO hosts (hostname)
      SELECT LOWER(host) FROM (
        SELECT (SELECT token FROM ts_debug(external_url) WHERE alias = 'host') AS host
        FROM adverts
        WHERE host_id IS NULL AND external_url IS NOT NULL
        GROUP BY host
      ) AS hosts
      WHERE host IS NOT NULL
      ON CONFLICT (hostname) DO NOTHING;
    POSTGRESQL

    UPDATE_ADVERTS = <<~POSTGRESQL
      UPDATE adverts
      SET host_id = hosts.id FROM hosts
      WHERE external_url IS NOT NULL AND host_id IS NULL
      AND hosts.hostname = (
        SELECT token FROM ts_debug(external_url) WHERE alias = 'host'
      );
    POSTGRESQL

    def self.run
      Host.transaction do
        $stderr.puts 'Inserting hosts...'
        ActiveRecord::Base.connection.execute(INSERT_HOSTS)
        $stderr.puts 'Updating adverts with host_ids...'
        ActiveRecord::Base.connection.execute(UPDATE_ADVERTS)
      end
    end
  end
end
