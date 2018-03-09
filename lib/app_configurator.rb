require 'logger'
require 'yaml'

require './lib/database_connector'

class AppConfigurator
  def configure
    setup_database
  end

  def get_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end

  def get_token
    YAML::load(IO.read('config/secret.yml'))['telegram_bot_token']
  end

  def self.get_personal_chat_id
    YAML::load(IO.read('config/secret.yml'))['personal_chat_id']
  end

  def self.get_admin_id
    YAML::load(IO.read('config/secret.yml'))['admin_id']
  end

  private

  def setup_database
    DatabaseConnector.establish_connection
  end
end
