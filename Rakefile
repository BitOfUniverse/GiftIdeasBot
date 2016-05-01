require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'active_record'
require 'yaml'

require './lib/database_connector'

def connection_details
  DatabaseConnector.configuration
end

def admin_connection
  connection_details.merge(
      {'database'=> 'postgres',
      'schema_search_path'=> 'public'}
  )
end

namespace :db do

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Migrator.migrate('db/migrate/')
  end

  desc 'Create the database'
  task :create do
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.create_database(connection_details.fetch('database'))
  end

  desc 'Drop the database'
  task :drop do
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
  end
end
