require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    strategy = example.metadata.fetch(:clean_database_with, :transaction)
    DatabaseCleaner.strategy = strategy
    DatabaseCleaner.clean_with(:truncation) if strategy == :truncation

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
