#shellcheck shell=bash

layout_poetry() {
    if ! has poetry; then
        # shellcheck disable=2016
        log_error 'layout_poetry: `poetry` is not in PATH'
        return 1
    fi

    if [[ ! -f pyproject.toml ]]; then
        # shellcheck disable=2016
        log_error 'layout_poetry: no pyproject.toml found. Use `poetry new` or `poetry init` to create one first'
        return 1
    fi

    # create venv if it doesn't exist
    poetry run true

    # shellcheck disable=2155
    export VIRTUAL_ENV=$(poetry env info --path)
    export POETRY_ACTIVE=1
    PATH_add "$VIRTUAL_ENV/bin"
    watch_file pyproject.toml
    watch_file poetry.lock
}
