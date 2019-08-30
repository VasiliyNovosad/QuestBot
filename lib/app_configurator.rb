require 'logger'
require 'yaml'

require_relative 'database_connector'

class AppConfigurator
  def configure
    setup_database
  end

  def get_logger
    file = File.open("#{File.expand_path File.dirname(__FILE__)}/../questbot.log", File::WRONLY | File::APPEND | File::CREAT)
    Logger.new(file, Logger::DEBUG)
  end

  def get_token
    ENV['TELEGRAM_BOT_TOKEN'] || YAML::load(IO.read("#{File.expand_path File.dirname(__FILE__)}/../config/secret.yml"))['telegram_bot_token']
  end

  def self.get_personal_chat_id
    (ENV['PERSONAL_CHAT_ID'] || YAML::load(IO.read("#{File.expand_path File.dirname(__FILE__)}/../config/secret.yml"))['personal_chat_id']).to_i
  end

  def self.get_admin_id
    (ENV['ADMIN_ID'] || YAML::load(IO.read("#{File.expand_path File.dirname(__FILE__)}/../config/secret.yml"))['admin_id']).to_i
  end

  private

  def setup_database
    DatabaseConnector.establish_connection
  end
end
