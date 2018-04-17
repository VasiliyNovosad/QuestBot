require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'active_record'
require 'yaml'

namespace :db do

  DATABASE_URI = ENV['DATABASE_URL'] || 'postgres://postgres:V0rtex@localhost:5432/questbot'

  desc 'Migrate the database'
  task :migrate do
    db = URI.parse(DATABASE_URI)
    connection_details = {
      adapter: db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      host: db.host,
      username: db.user,
      password: db.password,
      database: db.path[1..-1],
      encoding: 'utf8'
    }

    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Migrator.migrate('db/migrate/')
  end

  desc 'Create the database'
  task :create do
    db = URI.parse(DATABASE_URI)
    connection_details = {
        adapter: db.scheme == 'postgres' ? 'postgresql' : db.scheme,
        host: db.host,
        username: db.user,
        password: db.password,
        database: db.path[1..-1],
        encoding: 'utf8'
    }
    p connection_details

    admin_connection = connection_details.merge({database: 'postgres',
                                                 schema_search_path: 'public'})
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.create_database(connection_details.fetch(:database))
  end

  desc 'Drop the database'
  task :drop do
    db = URI.parse(DATABASE_URI)
    connection_details = {
        adapter: db.scheme == 'postgres' ? 'postgresql' : db.scheme,
        host: db.host,
        username: db.user,
        password: db.password,
        database: db.path[1..-1],
        encoding: 'utf8'
    }

    admin_connection = connection_details.merge({database: 'postgres',
                                                 schema_search_path: 'public'})
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.drop_database(connection_details.fetch(:database))
  end
end