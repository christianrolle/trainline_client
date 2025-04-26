if defined?(Rails::Console)
  Rails.logger = ActiveSupport::Logger.new(STDOUT)
  Rails.logger.level = Logger::DEBUG
end
