ENV['ENV'] ||= 'test'

require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

root = File.join(File.dirname(__FILE__), '..')
Dir[File.join(root, 'spec', 'support', '**', '*.rb')].each(&method(:require))

