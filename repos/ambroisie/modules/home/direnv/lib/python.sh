# shellcheck shell=bash

layout_poetry() {
    if ! has poetry; then
        # shellcheck disable=2016
        log_error 'layout_poetry: `poetry` is not in PATH'
        return 1
    fi

    if [[ ! -f pyproject.toml ]]; then
        # shellcheck disable=2016
        log_error 'layout_poetry: no pyproject.toml found. Use `poetry init` to create one first'
        return 1
    fi

    # create venv if it doesn't exist
    poetry run -q -- true

    # shellcheck disable=2155
    export VIRTUAL_ENV=$(poetry env info --path)
    export POETRY_ACTIVE=1
    PATH_add "$VIRTUAL_ENV/bin"
    watch_file pyproject.toml
    watch_file poetry.lock
}

layout_uv() {
    if ! has uv; then
        # shellcheck disable=2016
        log_error 'layout_uv: `uv` is not in PATH'
        return 1
    fi

    if [[ ! -f pyproject.toml ]]; then
        # shellcheck disable=2016
        log_error 'layout_uv: no pyproject.toml found. Use `uv init` to create one first'
        return 1
    fi

    local default_venv="$PWD/.venv"
    : "${VIRTUAL_ENV:=$default_venv}"

    # Use non-default venv path if required
    if [ "$VIRTUAL_ENV" != "$default_venv" ]; then
        export UV_PROJECT_ENVIRONMENT="$VIRTUAL_ENV"
    fi

    # create venv if it doesn't exist
    uv venv -q

    export VIRTUAL_ENV
    export UV_ACTIVE=1
    PATH_add "$VIRTUAL_ENV/bin"
    watch_file pyproject.toml
    watch_file uv.lock
}
