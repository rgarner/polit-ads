module PolitAds
  class TextSearchBackfill
    SQL = <<~SQL.freeze
      UPDATE adverts SET text_search = to_tsvector(external_text || ' ' || ad_creative_body)
      WHERE host_id IS NOT NULL
    SQL

    def self.run
      $stderr.puts 'Backfilling text_search...'
      ActiveRecord::Base.connection.execute(SQL)
    end
  end
end
