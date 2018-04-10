#!/bin/bash
whoami
ls /app
ls /app/bin

until PGPASSWORD=$POSTGRES_PASSWORD psql -h "postgres" -U "$POSTGRES_USER" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing startup"

$DIASPORA_PATH/bin/rake db:create
$DIASPORA_PATH/bin/rake db:migrate
$DIASPORA_PATH/script/server