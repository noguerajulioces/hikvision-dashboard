# Local backups for the desktop SQLite database.
#
# Uses SQLite's "VACUUM INTO", which produces a consistent copy even while the
# app is running (a plain file copy of a live WAL database can be corrupt).
#
# Usage:
#   bin/rails db:backup                 # -> <data dir>/backups/production-<timestamp>.sqlite3
#   BACKUP_DIR="E:/Multicarnes" bin/rails db:backup   # -> a chosen folder / USB drive
#
# The launcher also calls this before applying migrations on an update, so there
# is always a pre-migration snapshot to roll back to.

namespace :db do
  desc "Create a consistent backup of the primary SQLite database (VACUUM INTO)"
  task backup: :environment do
    keep = Integer(ENV.fetch("BACKUP_KEEP", "10"))

    data_dir = ENV["MULTICARNES_DATA_DIR"] || Rails.root.join("storage").to_s
    backup_dir = ENV["BACKUP_DIR"] || File.join(data_dir, "backups")
    FileUtils.mkdir_p(backup_dir)

    # Avoid Date.now/Time.now ambiguity across zones: stamp in local wall time.
    stamp = Time.now.strftime("%Y%m%d-%H%M%S")
    target = File.join(backup_dir, "production-#{stamp}.sqlite3")

    # VACUUM INTO fails if the file already exists.
    FileUtils.rm_f(target)
    ActiveRecord::Base.connection.execute("VACUUM INTO #{ActiveRecord::Base.connection.quote(target)}")

    size_kb = (File.size(target) / 1024.0).round(1)
    puts "Backup written: #{target} (#{size_kb} KB)"

    # Rotation: keep only the newest `keep` snapshots.
    snapshots = Dir.glob(File.join(backup_dir, "production-*.sqlite3")).sort
    (snapshots[0...-keep] || []).each do |old|
      File.delete(old)
      puts "Removed old backup: #{File.basename(old)}"
    end
  end
end
