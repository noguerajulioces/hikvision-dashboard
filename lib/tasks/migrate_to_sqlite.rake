# One-time data migration from the EC2 Postgres database into the local SQLite
# database used by the desktop build.
#
# It copies every business table at the *connection* level (raw SQL on both
# ends), deliberately bypassing all Active Record models. That avoids:
#   - validations / callbacks (e.g. AttendanceRecord#after_find re-saving rows,
#     AppSetting's method_missing landmine),
#   - the Paranoia default scope (soft-deleted employees are copied too),
#   - any password re-hashing (encrypted_password is copied verbatim).
# Original primary keys are preserved so foreign keys keep pointing at the right
# rows.
#
# Usage (run on the EC2, or through an SSH tunnel to the EC2 Postgres):
#
#   # 1. Create an EMPTY destination schema (no seeds!):
#   RAILS_ENV=production MULTICARNES_DATA_DIR=./tmp_migrate \
#     bin/rails db:create db:schema:load
#
#   # 2. Copy the data from Postgres into that SQLite file:
#   RAILS_ENV=production MULTICARNES_DATA_DIR=./tmp_migrate \
#     SOURCE_DATABASE_URL="postgres://postgres:password@localhost:5432/multicarnes_development" \
#     bin/rails data:migrate_to_sqlite
#
#   # 3. ./tmp_migrate/production.sqlite3 is now the seeded database the
#   #    installer ships to the client. (cache/queue/cable files can be left empty.)
#
# Env vars:
#   SOURCE_DATABASE_URL  (required)  connection URL of the source DB. Postgres for
#                                    the real migration; any AR-supported URL works
#                                    (e.g. sqlite3:/abs/path.sqlite3) for testing.
#   FORCE=1              (optional)  wipe the destination tables before copying,
#                                    instead of aborting when data already exists.

# Named (non-anonymous) class for the source connection pool. Active Record
# rejects anonymous classes in establish_connection because it keys the pool by
# class name.
class MulticarnesMigrationSource < ActiveRecord::Base
  self.abstract_class = true
end

namespace :data do
  # Parent tables first so foreign keys are always satisfiable. payroll_entries
  # is polymorphic over attendance_records / overtime_records / incidents, which
  # all appear earlier in the list.
  MIGRATION_TABLES = %w[
    groups
    devices
    roles
    users
    users_roles
    employees
    schedules
    attendance_records
    events
    absences
    incidents
    overtime_records
    payrolls
    payroll_entries
    settings
    app_settings
  ].freeze

  desc "Copy all data from SOURCE_DATABASE_URL (Postgres) into the local SQLite database"
  task migrate_to_sqlite: :environment do
    source_url = ENV["SOURCE_DATABASE_URL"]
    abort "SOURCE_DATABASE_URL is required (e.g. postgres://user:pass@host:5432/dbname)" if source_url.to_s.empty?

    dest = ActiveRecord::Base.connection
    abort "Destination must be SQLite (got #{dest.adapter_name}). Set RAILS_ENV/MULTICARNES_DATA_DIR." unless dest.adapter_name.downcase.include?("sqlite")

    # Separate connection pool for the source database.
    MulticarnesMigrationSource.establish_connection(source_url)
    source = MulticarnesMigrationSource.connection

    puts "Source:      #{source.adapter_name} (#{source_url.sub(/:[^:@\/]+@/, ':****@')})"
    puts "Destination: #{dest.adapter_name} -> #{ActiveRecord::Base.connection_db_config.database}"
    puts "-" * 72

    # Refuse to clobber an already-populated destination unless FORCE=1.
    existing = MIGRATION_TABLES.sum { |t| dest.select_value("SELECT COUNT(*) FROM #{dest.quote_table_name(t)}").to_i }
    if existing.positive? && ENV["FORCE"] != "1"
      abort "Destination already has #{existing} rows. Re-run with FORCE=1 to wipe and re-import."
    end

    # PRAGMA foreign_keys must be toggled outside any transaction to take effect.
    dest.execute("PRAGMA foreign_keys = OFF")

    if existing.positive?
      MIGRATION_TABLES.reverse_each { |t| dest.execute("DELETE FROM #{dest.quote_table_name(t)}") }
      puts "Wiped destination (FORCE=1)."
    end

    totals = {}
    MIGRATION_TABLES.each do |table|
      rows = source.select_all("SELECT * FROM #{source.quote_table_name(table)}").to_a
      if rows.empty?
        totals[table] = [ 0, 0 ]
        puts format("  %-20s source=%-7d dest=%-7d", table, 0, 0)
        next
      end

      columns = rows.first.keys
      quoted_columns = columns.map { |c| dest.quote_column_name(c) }.join(", ")

      rows.each_slice(500) do |slice|
        tuples = slice.map do |row|
          "(" + columns.map { |c| dest.quote(row[c]) }.join(", ") + ")"
        end.join(", ")
        dest.execute("INSERT INTO #{dest.quote_table_name(table)} (#{quoted_columns}) VALUES #{tuples}")
      end

      dest_count = dest.select_value("SELECT COUNT(*) FROM #{dest.quote_table_name(table)}").to_i
      totals[table] = [ rows.size, dest_count ]
      puts format("  %-20s source=%-7d dest=%-7d %s", table, rows.size, dest_count, rows.size == dest_count ? "OK" : "MISMATCH!")
    end

    # Re-enable and verify referential integrity.
    dest.execute("PRAGMA foreign_keys = ON")
    violations = dest.select_all("PRAGMA foreign_key_check").to_a
    puts "-" * 72
    if violations.any?
      puts "FOREIGN KEY VIOLATIONS: #{violations.size}"
      violations.first(20).each { |v| puts "  #{v.inspect}" }
    else
      puts "Foreign key check: OK"
    end

    mismatches = totals.select { |_t, (s, d)| s != d }
    if mismatches.any?
      abort "Row-count mismatches in: #{mismatches.keys.join(', ')}"
    else
      puts "All #{MIGRATION_TABLES.size} tables copied. Total rows: #{totals.values.sum { |(_s, d)| d }}"
    end
  ensure
    MulticarnesMigrationSource.remove_connection if MulticarnesMigrationSource.connected?
  end
end
