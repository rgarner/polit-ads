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

require 'polit_ads/ad_code_descriptions_loader'
require 'polit_ads/ad_code_value_descriptions_loader'
AdCodeDescriptionsLoader.new('doc/ad_codes').create_or_update
AdCodeValueDescriptionsLoader.new('doc/ad_code_values').create_or_update
