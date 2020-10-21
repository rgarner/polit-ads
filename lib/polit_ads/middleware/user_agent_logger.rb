module PolitAds
  module Middleware
    # Log user agents
    class UserAgentLogger
      def initialize(app)
        @app = app
      end

      def logger
        @logger ||= ActiveSupport::TaggedLogging.new(Rails.logger)
      end

      def call(env)
        logger.tagged('User-Agent') do
          logger.info env['HTTP_USER_AGENT']
        end
        @app.call(env)
      end
    end
  end
end
