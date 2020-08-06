# frozen_string_literal: true

module PolitAds
  ##
  # Point adverts at pre-db:seed'ed funding entities
  class FundingEntityPopulator
    UPDATE_ADVERTS = <<~POSTGRESQL
      UPDATE adverts a
      SET funding_entity_id = f.id FROM funding_entities f
      WHERE f.name = a.funding_entity AND a.external_url IS NOT NULL AND a.funding_entity_id IS NULL
    POSTGRESQL

    def self.populate
      FundingEntity.transaction do
        $stderr.puts 'Updating adverts with funding_entity_ids...'
        ActiveRecord::Base.connection.execute(UPDATE_ADVERTS)
      end
    end
  end
end
