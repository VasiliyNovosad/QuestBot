require 'logger'

class AppConfigurator
  def get_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end
end
