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
