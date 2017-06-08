require 'logger'

class AppConfigurator
  def get_token
    YAML::load(IO.read('config/secrets.yml'))['telegram_bot_token']
  end

  def get_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end

  def get_user(name)
    YAML::load(IO.read('config/secrets.yml'))['users'][name]
  end

end