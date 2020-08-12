# PolitAds

*yes, the name is not very good. It should be "decoding-trump"*

## Purpose

The project purpose is to decode the marketing parameters that the Trump presidential campaign Facebook adverts use
in order to provide a picture of the motivations and the running of the Trump online ad campaign.

## Technical approach
 
This project runs from a local mirror of the WTM `adverts` table with some column augmentations and
a few extra tables provided by ActiveRecord migrations. To get the database into shape for running
the eventual Rails app, the following things need to happen (nb this is only for local dev):

### 1. `rake db:seed`

Our own personal annotations for things are being added in `seeds.rb` to avoid writing an editor.
Seeds should be present before commencing. Because step 2. would take a while, I recommend we 
initialise our first hosted DB instance with a `pg_restore`

### 2. `make clean load-ads`

Removes/gets an `./adverts.csv` file from the WTM PG instance and loads it into the local DB. 
Requires an `ADS_PG_URL` env var. 

### 3. `rake ads:scrape ads:post_scrape`

#### 2.1 The `ads:scrape` task will:

1. Look for `adverts` locally with a `funding_entity` in our list of interest for Trump/Biden, taking
   most recent ads first.
2. Scrape the ads by rendering them in a headless browser to get the final `external_url` pointing
   to an FB-external site (e.g. action.donaldjtrump.com). This step also populates the `external_text`
   of the link and the `ad_library_url`.
   
#### 2.2 The `ads:post_scrape` task will:

1. Find all `adverts` needing their `external_url` parsed
2. Populate the `utm_campaign_values` table with values from the query string in the `external_url`
   in an EAV fashion
3. Also fill `adverts.utm_values` with the same values from step 2 but in a more queryable JSONB 
  `@>` fashion.
4. Extract the new hosts seen, fill the `hosts` table and point all adverts at their hosts
5. Point all adverts at previously-seeded `funding_entities` 
   
## How to schedule

Make sure the tasks run in order:

1. `make clean load-ads`
2. `rake ads:scrape ads:post_scrape`

### Issues that would need to be addressed

1. The scraper runs with a default limit of 1000 ads. They run over 3 headless browsers. This should
be tuned for any target environment; it's not parameterised right now, but can be made to take env vars.
2. `make clean load-ads` mirrors more stuff than we want; the local adverts table contains ads from
Greenpeace and the like. Probably `make load-ads` should only look for remote `adverts` with `funding_entity` in our list
of interest. 
3. The `rake ads:scrape` task is really set up to scrape what my laptop can handle. I tend to let it
   get all the new stuff and then run it in the background to backfill its historical data; it works
   backwards on `ad_creation_time`.


   




