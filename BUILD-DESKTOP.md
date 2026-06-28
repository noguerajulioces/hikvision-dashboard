# Multicarnes — Build de la app de escritorio (Windows)

Esta app Rails 8 se empaqueta como una app de escritorio **offline** para Windows:
Ruby + la app + wkhtmltopdf + una base **SQLite** local, todo dentro de un
instalador `.exe`. No requiere internet, Docker ni PostgreSQL en la PC del cliente.

- **Base de datos:** SQLite (4 archivos: primary/cache/queue/cable), en
  `%LOCALAPPDATA%\Multicarnes\data`.
- **Modo:** `production`.
- **Arranque:** `launcher\Multicarnes.vbs` → `rubyw.exe launch.rb` (sin consola)
  levanta Puma en `127.0.0.1:<puerto libre>` y abre el navegador.

> Las fases 1–3, 7 ya están implementadas y verificadas en este repo (branch
> `desktop-sqlite`). Las fases 4–6 (build nativo, empaquetado y prueba) se hacen
> en una **PC/VM con Windows x64** y se describen abajo.

---

## 0. Requisitos de la máquina de build (Windows x64)

1. **RubyInstaller2 con DevKit** para Ruby 3.4.x (x64): https://rubyinstaller.org/
   (instalar la variante "Ruby+Devkit"; ejecutar `ridk install` opción 1,3).
2. **Inno Setup 6**: https://jrsoftware.org/isdl.php (provee `iscc.exe`).
3. **wkhtmltopdf 0.12.6 (con Qt parcheado), build Windows**:
   https://wkhtmltopdf.org/downloads.html → descargar el ZIP/instalador y quedarse
   con `bin\wkhtmltopdf.exe` + sus DLLs.
4. El código de este repo (branch `desktop-sqlite`).
5. Un ícono `Multicarnes.ico`.

---

## 1. (Una sola vez) Migrar los datos del EC2 → SQLite  — Fase 2

La data real vive en el Postgres `multicarnes_development` dentro del EC2. Se
copia **una vez** a un archivo SQLite que el instalador entrega al cliente.

Correr **en el EC2** (o por un túnel SSH `ssh -L 5432:localhost:5432 ec2`):

```bash
# 1) Crear el esquema destino VACÍO (¡sin seeds!)
RAILS_ENV=production MULTICARNES_DATA_DIR=./tmp_migrate \
  bin/rails db:create db:schema:load

# 2) Copiar los datos de Postgres a SQLite
RAILS_ENV=production MULTICARNES_DATA_DIR=./tmp_migrate \
  SOURCE_DATABASE_URL="postgres://postgres:password@localhost:5432/multicarnes_development" \
  bin/rails data:migrate_to_sqlite
```

El task (`lib/tasks/migrate_to_sqlite.rake`) copia tabla por tabla a nivel de
conexión (sin modelos), preservando IDs, soft-deletes (paranoia) y los hashes
de password, y verifica counts + foreign keys. Resultado:
`./tmp_migrate/production.sqlite3` → ese es el `seed\production.sqlite3` del build.

> Verificación incluida en el task: counts origen=destino por tabla y
> `PRAGMA foreign_key_check`. Probá además el login de un usuario real.

---

## 2. (En Windows) Vendorizar gems + assets  — Fase 4

Desde una copia del repo en la PC de build:

```bat
:: Resolver dependencias incluyendo la plataforma Windows (el lock ya la trae)
bundle config set --local without "development test"
bundle config set --local path "vendor\bundle"
bundle install
:: ^ compila sqlite3/puma/nio4r/bootsnap con el DevKit; NO instala pg (grupo development)

:: Precompilar assets (Tailwind + Propshaft + importmap). Sin secret real:
set SECRET_KEY_BASE_DUMMY=1
set RAILS_ENV=production
bin\rails assets:precompile
```

Colocar wkhtmltopdf dentro de la app:

```
app\vendor\wkhtmltopdf\bin\wkhtmltopdf.exe   (+ DLLs)
```

(El initializer `config/initializers/wicked_pdf.rb` ya usa `WKHTMLTOPDF_PATH`,
que el launcher apunta a esa ruta.)

---

## 3. Armar la carpeta de staging  — Fase 6 (previo)

Crear `build\` con esta estructura:

```
build\
  ruby\                      <- copiar la instalación de RubyInstaller (portable)
  app\                       <- este repo, SIN .git, tmp\, log\, storage\*.sqlite3
                                CON vendor\bundle, public\assets, vendor\wkhtmltopdf
  launcher\                  <- launcher\launch.rb, Multicarnes.vbs, stop.cmd
  seed\production.sqlite3    <- el de la Fase 1 (opcional; si falta, la app crea una vacía con seeds)
  Multicarnes.ico
```

Notas:
- No copiar `app\storage\*.sqlite3` ni `app\.bundle` apuntando a rutas absolutas;
  el `.bundle\config` con `path = vendor\bundle` (relativo) es el que sirve.
- `ruby\` debe ser relocalizable (RubyInstaller lo es).

---

## 4. Compilar el instalador  — Fase 6

```bat
iscc.exe /DBuildDir="C:\ruta\a\build" installer\installer.iss
```

Genera `Output\MulticarnesSetup.exe`. Características (ver `installer\installer.iss`):
- Instala **por usuario** en `%LOCALAPPDATA%\Programs\Multicarnes` → **sin UAC**.
- Datos en `%LOCALAPPDATA%\Multicarnes\{data,logs,run}`, **separados** del programa.
- Copia `seed\production.sqlite3` **solo si no existe** (no pisa datos en reinstalación).
- Accesos directos en escritorio y menú inicio.

> Recomendado: **firmar** el `.exe` (certificado de firma de código) para evitar el
> bloqueo de SmartScreen. Sin firma, el cliente debe hacer "Más info → Ejecutar de todos modos".

---

## 5. Probar en una Windows LIMPIA (sin Ruby/PG)  — Fase 6 (verificación)

1. Doble clic en `MulticarnesSetup.exe` → instalar → ícono en escritorio.
2. Doble clic en el ícono → debe abrir el navegador en la app (sin consola negra).
3. Login con un usuario real (datos migrados) → revisar dashboard, empleados,
   generar un **PDF de payroll** (valida wkhtmltopdf), crear un registro.
4. Reiniciar la PC y reabrir → la data persiste.
5. Desinstalar → los datos en `%LOCALAPPDATA%\Multicarnes` **quedan**.
6. Reinstalar → la data sigue intacta (no se pisa).

Logs para diagnóstico: `%LOCALAPPDATA%\Multicarnes\logs\` (`launcher.log`, `production.log`).

---

## 6. Actualizaciones  — Fase 7

Para entregar una versión nueva:
1. Subir `MyAppVersion` en `installer\installer.iss` (mantener el mismo `AppId`).
2. Rehacer fases 2–4 (sin la migración de datos; esa es una sola vez) y recompilar.
3. El instalador reemplaza `{app}` pero **no toca** `%LOCALAPPDATA%\Multicarnes`.
4. En el siguiente arranque, el launcher hace **backup automático** del SQLite y
   corre `db:migrate` sobre la data del cliente.

## 7. Backups

- Automático: el launcher ejecuta `db:backup` antes de migrar en cada update.
- Manual: `bin\rails db:backup` (o un botón en la UI a futuro). Para copiar a un
  USB: `set BACKUP_DIR=E:\Multicarnes & bin\rails db:backup`.
- Restaurar: cerrar la app, reemplazar
  `%LOCALAPPDATA%\Multicarnes\data\production.sqlite3` por el backup, reabrir.

---

## Resumen de archivos del proyecto (branch `desktop-sqlite`)

| Archivo | Rol |
|---|---|
| `Gemfile` / `Gemfile.lock` | `sqlite3` (+ plataforma `x64-mingw-ucrt`); `pg` solo en `:development` |
| `config/database.yml` | 4 bases SQLite vía `MULTICARNES_DATA_DIR` |
| `config/environments/production.rb` | SSL off, logger a archivo, static files on |
| `config/initializers/wicked_pdf.rb` | usa `WKHTMLTOPDF_PATH` |
| `db/seeds.rb` | idempotente (`find_or_create_by!`) |
| `lib/tasks/migrate_to_sqlite.rake` | migración de datos EC2 → SQLite (Fase 2) |
| `lib/tasks/backup.rake` | `db:backup` (VACUUM INTO) (Fase 7) |
| `launcher/launch.rb` | arranque headless de Puma + abre navegador (Fase 5) |
| `launcher/Multicarnes.vbs` | corre el launcher sin consola |
| `launcher/stop.cmd` | detiene el servidor |
| `installer/installer.iss` | instalador Inno Setup (Fase 6) |

> Fixes de compatibilidad Postgres→SQLite aplicados en el código de la app
> (necesarios para correr en producción sobre SQLite): `home_controller.rb`,
> `services/time_metrics_service.rb`, `models/schedule.rb`,
> `controllers/admin/settings_controller.rb`, `views/home/index.html.erb`,
> `helpers/tailwind_paginate_renderer.rb`.
