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
    ENV['TELEGRAM_BOT_TOKEN'] || YAML::load(IO.read('config/secret.yml'))['telegram_bot_token']
  end

  def self.get_personal_chat_id
    (ENV['PERSONAL_CHAT_ID'] || YAML::load(IO.read('config/secret.yml'))['personal_chat_id']).to_i
  end

  def self.get_admin_id
    (ENV['ADMIN_ID'] || YAML::load(IO.read('config/secret.yml'))['admin_id']).to_i
  end

  private

  def setup_database
    DatabaseConnector.establish_connection
  end
end
