ENV['ENV'] ||= 'test'

require 'polit_ads'
require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

Dir[File.join(PolitAds.root, 'spec', 'support', '**', '*.rb')].each(&method(:require))

