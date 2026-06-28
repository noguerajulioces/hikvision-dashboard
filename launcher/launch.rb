# Multicarnes desktop launcher.
#
# Run by the bundled rubyw.exe (no console) via launcher\Multicarnes.vbs.
# Boots the Rails app headless on 127.0.0.1 and opens the default browser.
#
# Installed layout (see installer.iss):
#   <BASE>\ruby\       bundled Ruby (ruby.exe / rubyw.exe)
#   <BASE>\app\        the Rails application (vendor\bundle, public\assets, ...)
#   <BASE>\launcher\   this script + Multicarnes.vbs + stop.cmd
#
# Writable per-user data (survives updates/uninstall):
#   %LOCALAPPDATA%\Multicarnes\data\    *.sqlite3 + secret_key_base
#   %LOCALAPPDATA%\Multicarnes\logs\    launcher.log + production.log
#   %LOCALAPPDATA%\Multicarnes\run\     puma.pid + port

require "socket"
require "net/http"
require "securerandom"
require "fileutils"

BASE      = File.expand_path("..", __dir__)
APP_ROOT  = File.join(BASE, "app")
RUBY_DIR  = File.join(BASE, "ruby")
RUBYW     = File.join(RUBY_DIR, "bin", "rubyw.exe")
RAILS_BIN = File.join(APP_ROOT, "bin", "rails")

local_app_data = ENV["LOCALAPPDATA"] || File.join(ENV["USERPROFILE"].to_s, "AppData", "Local")
ROOT_DATA = File.join(local_app_data, "Multicarnes")
DATA_DIR  = File.join(ROOT_DATA, "data")
LOG_DIR   = File.join(ROOT_DATA, "logs")
RUN_DIR   = File.join(ROOT_DATA, "run")
[ DATA_DIR, LOG_DIR, RUN_DIR ].each { |d| FileUtils.mkdir_p(d) }

LAUNCH_LOG = File.join(LOG_DIR, "launcher.log")
PIDFILE    = File.join(RUN_DIR, "puma.pid")
PORTFILE   = File.join(RUN_DIR, "port")

def log(msg)
  File.open(LAUNCH_LOG, "a") { |f| f.puts("[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{msg}") }
rescue StandardError
  nil
end

def free_port
  server = TCPServer.new("127.0.0.1", 0)
  port = server.addr[1]
  server.close
  port
end

def up?(port)
  res = Net::HTTP.start("127.0.0.1", port, open_timeout: 1, read_timeout: 2) { |http| http.get("/up") }
  res.code.to_i == 200
rescue StandardError
  false
end

def wait_until_up(port, timeout: 90)
  deadline = Time.now + timeout
  until Time.now > deadline
    return true if up?(port)
    sleep 0.5
  end
  false
end

def open_browser(url)
  # `start` is a cmd builtin; the empty "" is the window title argument.
  system("cmd", "/c", "start", "", url)
end

# Secret is generated once per installation and kept out of the program folder.
def secret_key_base
  path = File.join(DATA_DIR, "secret_key_base")
  return File.read(path).strip if File.exist?(path)

  secret = SecureRandom.hex(64)
  File.write(path, secret)
  secret
end

# Spawn the bundled ruby running `bin/rails <args>`, logging to production.log.
# Blocks until the command finishes; returns true on success.
def run_rails(args, env)
  pid = Process.spawn(
    env,
    RUBYW, RAILS_BIN, *args,
    chdir: APP_ROOT,
    out: [ File.join(LOG_DIR, "production.log"), "a" ],
    err: [ :child, :out ]
  )
  _, status = Process.wait2(pid)
  status.success?
end

# --- Single-instance: if a live server is already running, just focus it. ---
if File.exist?(PORTFILE)
  existing = File.read(PORTFILE).strip.to_i
  if existing.positive? && up?(existing)
    log("Already running on port #{existing}; opening browser.")
    open_browser("http://127.0.0.1:#{existing}")
    exit 0
  end
end

env = {
  "RAILS_ENV"               => "production",
  "MULTICARNES_DATA_DIR"    => DATA_DIR,
  "SECRET_KEY_BASE"         => secret_key_base,
  "WKHTMLTOPDF_PATH"        => File.join(APP_ROOT, "vendor", "wkhtmltopdf", "bin", "wkhtmltopdf.exe"),
  "RAILS_SERVE_STATIC_FILES" => "1",
  "RAILS_MAX_THREADS"       => "3",
  "BUNDLE_GEMFILE"          => File.join(APP_ROOT, "Gemfile"),
  "PIDFILE"                 => PIDFILE
}

first_run = !File.exist?(File.join(DATA_DIR, "production.sqlite3"))

if first_run
  log("First run: creating database (db:prepare).")
  unless run_rails(%w[db:prepare], env)
    log("db:prepare FAILED. See production.log.")
    exit 1
  end
else
  # Update path: snapshot before applying any pending migrations.
  log("Existing database: backing up, then db:migrate.")
  run_rails(%w[db:backup], env)
  unless run_rails(%w[db:migrate], env)
    log("db:migrate FAILED. See production.log.")
    exit 1
  end
end

port = free_port
File.write(PORTFILE, port.to_s)
log("Starting Puma on 127.0.0.1:#{port}.")

server_env = env.merge("PORT" => port.to_s)
puma_pid = Process.spawn(
  server_env,
  RUBYW, RAILS_BIN, "server", "-e", "production", "-p", port.to_s, "-b", "127.0.0.1",
  chdir: APP_ROOT,
  out: [ File.join(LOG_DIR, "production.log"), "a" ],
  err: [ :child, :out ]
)
Process.detach(puma_pid)

if wait_until_up(port)
  log("Server is up; opening browser.")
  open_browser("http://127.0.0.1:#{port}")
  exit 0
else
  log("Server did not become healthy within timeout. See production.log.")
  open_browser("http://127.0.0.1:#{port}") # open anyway so the user sees the error
  exit 1
end
