# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

biden = Campaign.where(name: 'Joe Biden', slug: 'biden').first_or_create!
trump = Campaign.where(name: 'Donald J. Trump', slug: 'trump').first_or_create!

[
  'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE',
  'DONALD J. TRUMP FOR PRESIDENT, INC.'
].each do |entity_name|
  trump.funding_entities.where(name: entity_name).first_or_create!
end

[
  'BIDEN FOR PRESIDENT',
  'BIDEN VICTORY FUND',
  'Biden for President'
].each do |entity_name|
  biden.funding_entities.where(name: entity_name).first_or_create!
end

{
  'action.dccc.org' => { campaign: biden, purpose: 'data' },
  'action.donaldjtrump.com' => { campaign: trump, purpose: 'data' },
  'asians.donaldjtrump.com' => { campaign: trump, purpose: 'data' },
  'evangelicals.donaldjtrump.com' => { campaign: trump, purpose: 'data' },
  'events.donaldjtrump.com' => { campaign: trump, purpose: 'event' },
  'fb.com' => { campaign: nil,   purpose: 'video' },
  'forms.donaldjtrump.com' => { campaign: trump, purpose: 'data' },
  'go.joebiden.com' => { campaign: biden, purpose: 'data' },
  'itunes.apple.com' => { campaign: nil, purpose: 'app' },
  'joebiden.com' => { campaign: biden, purpose: 'data' },
  'play.google.com' => { campaign: nil,   purpose: 'app' },
  'secure.actblue.com' => { campaign: biden, purpose: 'funding' },
  'secure.winred.com' => { campaign: trump, purpose: 'funding' },
  'share.joebiden.com' => { campaign: biden, purpose: 'data' },
  'shop.donaldjtrump.com' => { campaign: trump, purpose: 'shop' },
  'www.barelytherebiden.com' => { campaign: trump, purpose: 'attack' },
  'www.donaldjtrump.com' => { campaign: trump, purpose: 'data' },
  'vote.donaldjtrump.com' => { campaign: trump, purpose: 'vote' },
  'www.youtube.com' => { campaign: nil, purpose: 'video' },
  'iwillvote.com' => { campaign: biden, purpose: 'vote' },
  'catholics.donaldjtrump.com' => { campaign: trump, purpose: 'data' },
  'f.io' => { campaign: biden, purpose: 'video' },
  'www.mobilize.us' => { campaign: biden, purpose: 'volunteer' },
  'joe.link' => { campaign: biden, purpose: 'event' },
  'www.joebiden.com' => { campaign: biden, purpose: 'data' },
  'stories.joebiden.com' => { campaign: biden, purpose: 'data' },
  'gazette.com' => { campaign: biden, purpose: 'news' },
  'www.organizenh.org' => { campaign: biden, purpose: 'news' },
  'www.mesabitribune.com' => { campaign: biden, purpose: 'news' },
  'www.theatlantic.com' => { campaign: biden, purpose: 'news' },
  'www.nbcnews.com' => { campaign: biden, purpose: 'news' },
  'www.battlecreekenquirer.com' => { campaign: biden, purpose: 'news' },
  'www.detroitnews.com' => { campaign: biden, purpose: 'news' },
  'orgnh.us' => { campaign: biden, purpose: 'news' },
  'sentinelcolorado.com' => { campaign: biden, purpose: 'news' },
  'www.coloradopolitics.com' => { campaign: biden, purpose: 'news' },
  'people.com' => { campaign: biden, purpose: 'news' },
  'www.fox6now.com' => { campaign: biden, purpose: 'news' },
  'www.bloomberg.com' => { campaign: biden, purpose: 'news' },
  'www.ft.com' => { campaign: biden, purpose: 'news' },
  'www.thefiscaltimes.com' => { campaign: biden, purpose: 'news' },
  'mashable.com' => { campaign: biden, purpose: 'news' },
  'www.vox.com' => { campaign: biden, purpose: 'news' },
  'apnews.com' => { campaign: biden, purpose: 'news' },
  'www.wtsp.com' => { campaign: biden, purpose: 'news' },
  'www.foxnews.com' => { campaign: biden, purpose: 'news' },
  'nymag.com' => { campaign: biden, purpose: 'news' },
  'www.ncronline.org' => { campaign: biden, purpose: 'news' },
  'es-us.noticias.yahoo.com' => { campaign: biden, purpose: 'news' },
  'www.cnn.com' => { campaign: biden, purpose: 'news' },
  'www.forbes.com' => { campaign: biden, purpose: 'news' },
  'request.iwillvote.com' => { campaign: biden, purpose: 'vote' },
  'www.makeaplan.com' => { campaign: biden, purpose: 'vote' },
  'www.inquirer.com' => { campaign: biden, purpose: 'news' },
  'www.mlive.com' => { campaign: biden, purpose: 'news' },
  'www.reuters.com' => { campaign: biden, purpose: 'news' },
  'JoeBiden.com' => { campaign: biden, purpose: 'data' },
  '0z.io' => { campaign: biden, purpose: 'news' },
  'mobilize.us' => { campaign: biden, purpose: 'volunteer' },
  'voyavotar.com' => { campaign: biden, purpose: 'news' },
  'www.erienewsnow.com' => { campaign: nil, purpose: 'news' },
  'www.fox21news.com' => { campaign: nil, purpose: 'news' },
  'www.meadvilletribune.com' => { campaign: nil, purpose: 'news' },
  'mlive.com' => { campaign: nil, purpose: 'news' },
  'pittsburgh.cbslocal.com' => { campaign: nil, purpose: 'news' },
  'www.freep.com' => { campaign: nil, purpose: 'news' },
  'www.hollandsentinel.com' => { campaign: nil, purpose: 'news' },
  'www.tribdem.com' => { campaign: nil, purpose: 'news' },
  'makeaplan.com' => { campaign: biden, purpose: 'vote' },
  'triblive.com' => { campaign: nil, purpose: 'news' },
  'www.13abc.com' => { campaign: nil, purpose: 'news' },
  'www.cbsnews.com' => { campaign: nil, purpose: 'news' },
  'www.iwillvote.com' => { campaign: nil, purpose: 'vote' },
  'www.penncapital-star.com' => { campaign: nil, purpose: 'news' },
  'www.usatoday.com' => { campaign: nil, purpose: 'news' },
  'www.wsj.com' => { campaign: nil, purpose: 'news' },
  'apps.bostonglobe.com' => { campaign: nil, purpose: 'news' },
  'lasvegassun.com' => { campaign: nil, purpose: 'news' },
  'madison.com' => { campaign: nil, purpose: 'news' },
  'omaha.com' => { campaign: nil, purpose: 'news' },
  'tucson.com' => { campaign: nil, purpose: 'news' },
  'www.cleveland.com' => { campaign: nil, purpose: 'news' },
  'www.desmoinesregister.com' => { campaign: nil, purpose: 'news' },
  'www.sentinelsource.com' => { campaign: nil, purpose: 'news' },
  'www.tampabay.com' => { campaign: nil, purpose: 'news' },
  'www.thetimes-tribune.com' => { campaign: nil, purpose: 'news' },
  'www.fox2detroit.com' => { campaign: nil, purpose: 'news' },
  'www.msnbc.com' => { campaign: nil, purpose: 'news' },
  'www.theoaklandpress.com' => { campaign: nil, purpose: 'news' },
  'www.coloradoan.com' => { campaign: nil, purpose: 'news' },
  'txdem.co' => { campaign: biden, purpose: 'vote' },
  'www.newsobserver.com' => { campaign: nil, purpose: 'news' },
  'www.elnuevodia.com' => { campaign: nil, purpose: 'news' },
  'www.glamour.com' => { campaign: nil, purpose: 'news' },
  'www.newsweek.com' => { campaign: nil, purpose: 'news' },
  'www.npr.org' => { campaign: nil, purpose: 'news' },
  'www.refinery29.com' => { campaign: nil, purpose: 'news' },
  'www.vanityfair.com' => { campaign: nil, purpose: 'news' },
  'vote.wisdems.org' => { campaign: biden, purpose: 'vote' },
  'www.voyavotar.com' => { campaign: biden, purpose: 'vote' },
  'joebiden.es' => { campaign: biden, purpose: 'funding' },
  'elsemanariocolorado.com' => { campaign: nil, purpose: 'news' },
  'www.9news.com' => { campaign: nil, purpose: 'news' },
  'www.charlescitypress.com' => { campaign: nil, purpose: 'news' },
  'www.lavozarizona.com' => { campaign: nil, purpose: 'news' },
  'www.univision.com' => { campaign: nil, purpose: 'news' },
  'www.gjsentinel.com' => { campaign: nil, purpose: 'news' }
}.each_pair do |hostname, data|
  host = Host.where(hostname: hostname).first
  host&.update(campaign: data[:campaign], purpose: data[:purpose])
end

require 'polit_ads/ad_code_descriptions_loader'
require 'polit_ads/ad_code_value_descriptions_loader'
AdCodeDescriptionsLoader.new('doc/ad_codes').create_or_update
AdCodeValueDescriptionsLoader.new('doc/ad_code_values').create_or_update
