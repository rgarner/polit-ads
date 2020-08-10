# frozen_string_literal: true

module PolitAds
  ##
  # Point adverts at pre-db:seed'ed funding entities
  class UtmValuesPopulator
    UPDATE_ADVERTS = <<~POSTGRESQL
      UPDATE adverts SET utm_values = (
          '{ ' ||
              '"0": "' || utm0 || '",' ||
              '"1": "' || utm1 || '",' ||
              '"2": "' || utm2 || '",' ||
              '"3": "' || utm3 || '",' ||
              '"4": "' || utm4 || '",' ||
              '"5": "' || utm5 || '",' ||
              '"6": "' || utm6 || '",' ||
              '"7": "' || utm7 || '",' ||
              '"8": "' || utm8 || '",' ||
              '"9": "' || utm9 || '",' ||
              '"10": "' || utm10 || '",' ||
              '"11": "' || utm11 || '",' ||
              '"12": "' || utm12 || '",' ||
              '"13": "' || utm13 || '",' ||
              '"14": "' || utm14 || '",' ||
              '"15": "' || utm15 || '",' ||
              '"16": "' || utm16 || '",' ||
              '"17": "' || utm17 || '",' ||
              '"18": "' || utm18 || '",' ||
              '"19": "' || utm19 || '",' ||
              '"20": "' || utm20 || '",' ||
              '"21": "' || utm21 || '",' ||
              '"22": "' || utm22 || '"' ||
          '}'
      )::jsonb
      FROM
      (
          SELECT advert_id,utm0,utm1,utm2,utm3,utm4,utm5,utm6,utm7,utm8,utm9,utm10,utm11,utm12,utm13,utm14,utm15,utm16,
                           utm17,utm18,utm19,utm20,utm21,utm22
          FROM crosstab(
                       'SELECT advert_id, index, value
                        FROM utm_campaign_values
                        ORDER BY 1,2'
                   )
                   AS ct(advert_id bigint,
                         utm0 character varying, utm1 character varying, utm2 character varying, utm3 character varying,
                         utm4 character varying, utm5 character varying, utm6 character varying, utm7 character varying,
                         utm8 character varying, utm9 character varying, utm10 character varying, utm11 character varying,
                         utm12 character varying, utm13 character varying, utm14 character varying, utm15 character varying,
                         utm16 character varying, utm17 character varying, utm18 character varying, utm19 character varying,
                         utm20 character varying, utm21 character varying, utm22 character varying)
          GROUP BY advert_id, utm0, utm1, utm2, utm3, utm4, utm5, utm6, utm7, utm8, utm9, utm10, utm11, utm12,
                   utm13, utm14, utm15, utm16, utm17, utm18, utm19, utm20, utm21, utm22
          ORDER BY advert_id
      ) utm_values
      WHERE adverts.id = utm_values.advert_id AND host_id IS NOT NULL AND utm_values IS NULL;
    POSTGRESQL

    def self.populate
      Advert.transaction do
        $stderr.puts 'Updating adverts.utm_values jsonb...'
        ActiveRecord::Base.connection.execute(UPDATE_ADVERTS)
      end
    end
  end
end
