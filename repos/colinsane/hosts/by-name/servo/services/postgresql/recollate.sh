#!/bin/sh
# source: <https://gist.githubusercontent.com/troykelly/616df024050dd50744dde4a9579e152e/raw/fe84e53cedf0caa6903604894454629a15867439/reindex_and_refresh_collation.sh>
#
# run this whenever postgres complains like:
# > WARNING:  database "gitea" has a collation version mismatch
# > DETAIL:  The database was created using collation version 2.39, but the operating system provides version 2.40.
# > HINT:  Rebuild all objects in this database that use the default collation and run ALTER DATABASE gitea REFRESH COLLATION VERSION, or build PostgreSQL with the right library version.
#
# this script checks which databases are in need of a collation update,
# and re-collates them as appropriate.
# invoking this script should have low perf impact in the non-upgrade case,
# so safe to do this as a cron job.
#
# invoke as postgres user

log_info() {
  >&2 echo "$@"
}

list_databases() {
  log_info "Retrieving list of databases from the PostgreSQL server..."
  psql --dbname="postgres" -Atc \
    "SELECT datname FROM pg_database WHERE datistemplate = false"
}

refresh_collation_version() {
  local db=$1
  log_info "Refreshing collation version for database: $db..."
  psql --dbname="$db" -c \
    "ALTER DATABASE \"$db\" REFRESH COLLATION VERSION;"
}

check_collation_mismatches() {
  local error=
  log_info "Checking for collation mismatches in all databases..."
  # Loop through each database and check for mismatching collations in table columns.
  while IFS= read -r db; do
    if [ -n "$db" ]; then
      log_info "Checking database: $db for collation mismatches..."
      local mismatches=$(psql --dbname="$db" -Atc \
        "SELECT 'Mismatch in table ' || table_name || ' column ' || column_name || ' with collation ' || collation_name
         FROM information_schema.columns
         WHERE collation_name IS NOT NULL AND collation_name <> 'default' AND table_schema = 'public'
         EXCEPT
         SELECT 'No mismatch - default collation of ' || datcollate || ' used.'
         FROM pg_database WHERE datname = '$db';"
      )
      if [ -z "$mismatches" ]; then
        log_info "No collation mismatches found in database: $db"
      else
        # Print an informational message to stderr.
        log_info "Collation mismatches found in database: $db:"
        log_info "$mismatches"
        error=1
      fi
    fi
  done

  if [ -n "$error" ]; then
    exit 1
  fi
}

log_info "Starting the reindexing and collation refresh process for all databases..."

databases=$(list_databases)

if [ -z "$databases" ]; then
  log_info "No databases found for reindexing or collation refresh. Please check connection details to PostgreSQL server."
  exit 1
fi

for db in $databases; do
  refresh_collation_version "$db"
done

# Checking for collation mismatches after reindexing and collation refresh.
# Pass the list of databases to the check_collation_mismatches function through stdin.
echo "$databases" | check_collation_mismatches

log_info "Reindexing and collation refresh process completed."
