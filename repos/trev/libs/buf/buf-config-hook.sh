# shellcheck shell=bash

bufConfigHook() {
    echo "Executing bufConfigHook"

    if [ -n "${bufRoot-}" ]; then
      pushd "$bufRoot" || exit 1
    fi

    if [ -z "${bufDeps-}" ]; then
      echo "Error: 'bufDeps' must be set when using pnpmConfigHook."
      exit 1
    fi

    echo "Configuring buf cache"

    HOME=$(mktemp -d)
    export HOME

    STORE_PATH=$(mktemp -d)
    export STORE_PATH

    cp -Tr "$bufDeps" "$STORE_PATH"
    chmod -R +w "$STORE_PATH"

    export BUF_CACHE_DIR="$STORE_PATH"

    echo "Installing dependencies"

    if ! buf dep graph
    then
        echo
        echo "ERROR: buf failed to install dependencies"
        echo

        exit 1
    fi

    if [ -n "${bufRoot-}" ]; then
      popd || exit 1
    fi

    echo "Finished bufConfigHook"
}

postConfigureHooks+=(bufConfigHook)
