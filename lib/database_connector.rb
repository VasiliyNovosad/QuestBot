require 'active_record'
require 'logger'
require 'yaml'

class DatabaseConnector
  class << self
    def establish_connection
      ActiveRecord::Base.logger = Logger.new(active_record_logger_path)

      configuration = if File.exist?(database_config_path)
                        YAML::load(IO.read(database_config_path))
                      else
                        {
                          adapter: 'postgresql',
                          pool: 10,
                          timeout: 5000,
                          database_url: ENV['DATABASE_URL'] || 'postgres://postgres:V0rtex@localhost:5432/questbot'
                        }
                      end
      # configuration = {
      #     adapter: 'postgresql',
      #     pool: 10,
      #     timeout: 5000,
      #     database_url: ENV['DATABASE_URL'] || 'postgres://postgres:V0rtex@localhost:5432/questbot'
      # }

      ActiveRecord::Base.establish_connection("#{configuration['database_url']}?adapter=#{configuration['adapter'] || 'postgresql'}&pool=#{configuration['pool'] || 10}&timeout=#{configuration['timeout'] || 5000}")
    end

    private

    def active_record_logger_path
      "#{File.expand_path File.dirname(__FILE__)}/../logger.log"
    end

    def database_config_path
      "#{File.expand_path File.dirname(__FILE__)}/../config/database.yml"
    end
  end
end