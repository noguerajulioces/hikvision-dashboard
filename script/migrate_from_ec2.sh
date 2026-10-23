#!/usr/bin/env bash
# Migra la base Postgres del EC2 a un production.sqlite3 para la app de escritorio.
#
# Uso:
#   script/migrate_from_ec2.sh usuario@ip-del-ec2 [ruta/a/llave.pem]
#
# Requisitos en TU computadora: ruta de este repo, Ruby con `bundle install`
# hecho (incluye la gem pg) y acceso SSH al EC2. En Windows, usar Git Bash o WSL.
# El Postgres corre en Docker en el EC2 (contenedor postgres_db, puerto 5432
# publicado); las credenciales se pueden cambiar con PGUSER/PGPASSWORD/PGDATABASE.
#
# Resultado: ./tmp_migrate/production.sqlite3 (copiarlo a
# %LOCALAPPDATA%\Multicarnes\data\ en la PC del cliente) y un respaldo
# ./tmp_migrate/respaldo-AAAAMMDD-HHMMSS.sql (pg_dump completo).
set -euo pipefail

HOST="${1:?Uso: $0 usuario@ip-del-ec2 [llave.pem]}"
KEY="${2:-}"
PGUSER="${PGUSER:-postgres}"
PGPASSWORD="${PGPASSWORD:-password}"
PGDATABASE="${PGDATABASE:-multicarnes_development}"
CONTAINER="${PG_CONTAINER:-postgres_db}"
LOCAL_PORT="${LOCAL_PORT:-5433}"
OUT_DIR="./tmp_migrate"

SSH_OPTS=(-o ExitOnForwardFailure=yes)
[ -n "$KEY" ] && SSH_OPTS+=(-i "$KEY")

cd "$(dirname "$0")/.."
mkdir -p "$OUT_DIR"

if [ -e "$OUT_DIR/production.sqlite3" ]; then
  echo "Ya existe $OUT_DIR/production.sqlite3. Muévelo o bórralo antes de seguir." >&2
  exit 1
fi

echo "==> 1/4 Respaldo completo con pg_dump (solo como seguro)"
STAMP="$(date +%Y%m%d-%H%M%S)"
ssh "${SSH_OPTS[@]}" "$HOST" "docker exec $CONTAINER pg_dump -U $PGUSER $PGDATABASE" > "$OUT_DIR/respaldo-$STAMP.sql"
[ -s "$OUT_DIR/respaldo-$STAMP.sql" ] || { echo "El respaldo quedó vacío; abortando." >&2; exit 1; }
echo "    $OUT_DIR/respaldo-$STAMP.sql ($(wc -c < "$OUT_DIR/respaldo-$STAMP.sql") bytes)"

echo "==> 2/4 Abriendo túnel SSH a Postgres (localhost:$LOCAL_PORT)"
ssh "${SSH_OPTS[@]}" -N -L "$LOCAL_PORT:localhost:5432" "$HOST" &
TUNNEL_PID=$!
trap 'kill $TUNNEL_PID 2>/dev/null || true' EXIT
sleep 3
kill -0 "$TUNNEL_PID" 2>/dev/null || { echo "No se pudo abrir el túnel SSH." >&2; exit 1; }

export RAILS_ENV=production
export MULTICARNES_DATA_DIR="$OUT_DIR"
export SECRET_KEY_BASE_DUMMY=1

echo "==> 3/4 Creando el esquema SQLite vacío"
bin/rails db:create db:schema:load

echo "==> 4/4 Copiando los datos"
SOURCE_DATABASE_URL="postgres://$PGUSER:$PGPASSWORD@localhost:$LOCAL_PORT/$PGDATABASE" \
  bin/rails data:migrate_to_sqlite

echo
echo "Listo: $OUT_DIR/production.sqlite3"
echo "Revisá arriba que todas las tablas digan OK y 'Foreign key check: OK'."
