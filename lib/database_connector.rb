require 'active_record'
require 'logger'

class DatabaseConnector
  class << self
    def establish_connection
      ActiveRecord::Base.logger = Logger.new(active_record_logger_path)

      # configuration = YAML::load(IO.read(database_config_path))
      configuration = {
          adapter: 'postgresql',
          pool: 10,
          timeout: 5000,
          database_url: ENV['DATABASE_URL'] || 'postgres://postgres:V0rtex@localhost:5432/questbot'
      }

      ActiveRecord::Base.establish_connection(configuration)
    end

    private

    def active_record_logger_path
      'debug.log'
    end

    # def database_config_path
    #   'config/database.yml'
    # end
  end
end