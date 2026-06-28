# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# controller by copying the appropriate line in a before_action.

WickedPdf.configure do |config|
  # Path to the wkhtmltopdf executable: This will work on macOS with Homebrew or on Ubuntu
  config.exe_path = (
    # Desktop build: the launcher points WKHTMLTOPDF_PATH at the wkhtmltopdf.exe
    # bundled inside the app, so no system-wide install is required.
    if ENV["WKHTMLTOPDF_PATH"].present? && File.exist?(ENV["WKHTMLTOPDF_PATH"])
      ENV["WKHTMLTOPDF_PATH"]
    elsif Gem.win_platform?
      # Windows
      "C:/Program Files/wkhtmltopdf/bin/wkhtmltopdf.exe"
    elsif File.exist?("/usr/local/bin/wkhtmltopdf")
      # macOS (Homebrew)
      "/usr/local/bin/wkhtmltopdf"
    elsif File.exist?("/usr/bin/wkhtmltopdf")
      # Ubuntu/Debian
      "/usr/bin/wkhtmltopdf"
    else
      # Try to find it in PATH
      Gem.win_platform? ? "wkhtmltopdf.exe" : "wkhtmltopdf"
    end
  )
end
