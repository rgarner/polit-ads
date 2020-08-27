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
  'vote.donaldjtrump.com' => { campaign: trump, purpose: 'data' },
  'www.youtube.com' => { campaign: nil, purpose: 'video' },
  'iwillvote.com' => { campaign: biden, purpose: 'data' },
  'catholics.donaldjtrump.com' => { campaign: trump, purpose: 'data' },
}.each_pair do |hostname, data|
  host = Host.where(hostname: hostname).first
  host&.update(campaign: data[:campaign], purpose: data[:purpose])
end

{
  '0' => { name: 'Creation date', quality: 1 },
  '1' => { name: 'Donor action', quality: 5 },
  '2' => { name: 'Ad campaign', quality: 3 },
  '3' => { name: 'Page', quality: 4 },
  '4' => { name: 'Funding entity', quality: 2 },
  '5' => { name: 'Facebook objective', quality: 4 },
  '6' => { name: 'Audience type', quality: 4 },
  '7' => { name: 'Audience ID', quality: 2 },
  '8' => { name: 'Creative ID', quality: 2 },
  '9' => { name: 'Copy ID', quality: 2 },
  '10' => { name: 'FB Geo', quality: 3 },
  '11' => { name: 'Genders', quality: 1 },
  '12' => { name: 'Age range', quality: 2 },
  '13' => { name: 'Ad network', quality: 2 },
  '14' => { name: 'Constant14', quality: 0 },
  '15' => { name: 'Unused age range', quality: 0 },
  '16' => { name: 'Ad LP code', quality: 0 },
  '17' => { name: 'Ad goal', quality: 4 },
  '18' => { name: 'Facebook optimisation goal', quality: 3 },
  '19' => { name: 'Asset type', quality: 2 },
  '20' => { name: 'Asset display width', quality: 1 },
  '21' => { name: 'Asset display height', quality: 1 },
  '22' => { name: 'Video length', quality: 1 }
}.each_pair do |index, values|
  ad_code = AdCode.where(index: index, campaign: trump).first_or_create

  ad_code.name = values[:name]
  ad_code.slug = values[:name].downcase.gsub(' ', '-')
  ad_code.quality = values[:quality]

  ad_code.save!
end

require 'polit_ads/ad_code_value_descriptions_loader'
AdCodeValueDescriptionsLoader.new('doc/ad_code_values').create_or_update
