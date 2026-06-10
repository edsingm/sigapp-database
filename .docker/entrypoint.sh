#!/bin/bash
set -e

# Inicia o postgres normalmente em background
docker-entrypoint.sh postgres &
PG_PID=$!

# Aguarda o postgres ficar pronto
until pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -q; do
    sleep 0.5
done

# Garante que o schema public existe em todo startup
psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "
    CREATE SCHEMA IF NOT EXISTS public;
    GRANT ALL ON SCHEMA public TO ${POSTGRES_USER};
    GRANT ALL ON SCHEMA public TO public;
" > /dev/null 2>&1

wait $PG_PID
