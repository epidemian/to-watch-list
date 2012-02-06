namespace :db do
  require 'sequel'
  require 'logger'
  desc 'Migrates the database to a given version or to the last version.'
  task :migrate, [:version] do |task, args|
    raise 'No DATABASE_URL environment variable' unless ENV['DATABASE_URL']
    db  = Sequel.connect ENV['DATABASE_URL'], :loggers => [Logger.new($stdout)]
    dir = File.join 'db', 'migrations'

    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel::Migrator.run db, dir, :target => version
  end
end