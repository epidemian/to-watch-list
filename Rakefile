namespace :db do
  require 'sequel'
  desc 'Migrates the database to a given version.'
  task :migrate, [:version] do |task, args|
    raise 'No DATABASE_URL environment variable' unless ENV['DATABASE_URL']
    db  = Sequel.connect ENV['DATABASE_URL']
    dir = File.join 'db', 'migrations'

    Sequel.extension :migration
    Sequel::Migrator.run db, dir, :target => args[:version].to_i
  end
end