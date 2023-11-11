#shellcheck shell=bash

layout_postgres() {
    if ! has postgres || ! has initdb; then
        # shellcheck disable=2016
        log_error 'layout_postgres: `postgres` and `initdb` are not in PATH'
        return 1
    fi

    # shellcheck disable=2155
    export PGDATA="$(direnv_layout_dir)/postgres"
    export PGHOST="$PGDATA"

    if [[ ! -d "$PGDATA" ]]; then
        initdb
        cat >> "$PGDATA/postgresql.conf" << EOF
listen_addresses = ''
unix_socket_directories = '$PGHOST'
EOF
        echo "CREATE DATABASE $USER;" | postgres --single -E postgres
    fi
}
