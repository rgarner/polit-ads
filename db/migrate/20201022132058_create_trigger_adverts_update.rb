# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggerAdvertsUpdate < ActiveRecord::Migration[6.0]
  def up
    create_trigger("adverts_after_update_of_external_text_ad_creative_body_row_tr", :generated => true, :compatibility => 1).
        on("adverts").
        after(:update).
        of(:external_text, :ad_creative_body) do
      <<-SQL
        UPDATE adverts SET text_search = to_tsvector(external_text || ' ' || ad_creative_body)
        WHERE id = NEW.id;
      SQL
    end
  end

  def down
    drop_trigger("adverts_after_update_of_external_text_ad_creative_body_row_tr", "adverts", :generated => true)
  end
end
