; Inno Setup script for the Multicarnes desktop app (Windows, offline, per-user).
;
; Build it with Inno Setup 6 (iscc.exe) on a Windows machine, pointing BuildDir
; at the staging folder produced by the build steps in BUILD.md:
;
;   <BuildDir>\
;     ruby\                     RubyInstaller portable (ruby.exe, rubyw.exe, ...)
;     app\                      the Rails app (vendor\bundle, public\assets,
;                               vendor\wkhtmltopdf\bin\wkhtmltopdf.exe, ...)
;     launcher\                 launch.rb, Multicarnes.vbs, stop.cmd
;     seed\production.sqlite3   (optional) the migrated client database
;     Multicarnes.ico
;
;   iscc.exe /DBuildDir="C:\path\to\build" installer.iss
;
; Installs per-user (no admin / no UAC) and keeps all data outside the program
; folder so updates and uninstalls never touch it.

#ifndef BuildDir
  #define BuildDir "build"
#endif
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#define MyAppName "Multicarnes"
#define MyAppPublisher "Multicarnes"

[Setup]
; Keep this AppId stable forever so future versions update in place.
AppId={{B8E6A0C2-3F4D-4E2A-9C1B-7A5D2E9F1A33}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputBaseFilename={#MyAppName}Setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
SetupIconFile={#BuildDir}\Multicarnes.ico
UninstallDisplayIcon={app}\Multicarnes.ico
UninstallDisplayName={#MyAppName}

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear un acceso directo en el escritorio"; GroupDescription: "Accesos directos:"

[Dirs]
; Per-user writable data, kept separate from the program so updates/uninstall
; never delete it.
Name: "{localappdata}\{#MyAppName}\data"
Name: "{localappdata}\{#MyAppName}\logs"
Name: "{localappdata}\{#MyAppName}\run"

[Files]
Source: "{#BuildDir}\ruby\*";     DestDir: "{app}\ruby";     Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#BuildDir}\app\*";      DestDir: "{app}\app";      Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#BuildDir}\launcher\*"; DestDir: "{app}\launcher"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#BuildDir}\Multicarnes.ico"; DestDir: "{app}"; Flags: ignoreversion
; Ship the migrated database ONLY on a clean install; never overwrite the
; client's live data on reinstall/upgrade. The file is packaged into the setup
; when present at build time; skipifsourcedoesntexist lets CI builds compile
; without it (the app then creates an empty seeded DB on first run).
Source: "{#BuildDir}\seed\production.sqlite3"; DestDir: "{localappdata}\{#MyAppName}\data"; Flags: onlyifdoesntexist skipifsourcedoesntexist

[Icons]
Name: "{group}\{#MyAppName}";          Filename: "{app}\launcher\Multicarnes.vbs"; IconFilename: "{app}\Multicarnes.ico"
Name: "{group}\Detener {#MyAppName}";  Filename: "{app}\launcher\stop.cmd";        IconFilename: "{app}\Multicarnes.ico"
Name: "{autodesktop}\{#MyAppName}";    Filename: "{app}\launcher\Multicarnes.vbs"; IconFilename: "{app}\Multicarnes.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\launcher\Multicarnes.vbs"; Description: "Iniciar {#MyAppName} ahora"; Flags: shellexec nowait postinstall skipifsilent

; Note: no [UninstallDelete] for {localappdata}\{#MyAppName} — the client's data
; and backups are intentionally preserved after uninstall.
