# shellcheck shell=bash
# Functions for mkUvPackage, using the variables it sets.

# the home directory isn't writable
export UV_CACHE_DIR="$NIX_BUILD_TOP/.uv-cache"

# exports the requirements of the lock with their hashes
uvExport() {
    # shellcheck disable=SC2154,SC2086
    uv export $uvExportFlags $uvExcludeFlags --output-file "$NIX_BUILD_TOP/requirements.txt"
    if [ -n "${doCheck-}" ]; then
        # shellcheck disable=SC2154,SC2086
        uv export $uvCheckExportFlags $uvExcludeFlags --output-file "$NIX_BUILD_TOP/requirements-check.txt"
    fi
}

# builds the project's wheel, unless it's virtual
uvBuild() {
    # shellcheck disable=SC2154
    if [ -n "$uvBuildPython" ]; then
        # backends like uv_build run executables from the environment
        PATH="$(dirname "$uvBuildPython"):$PATH" \
            "$uvBuildPython" -m build --wheel --no-isolation --skip-dependency-check \
            --outdir "$NIX_BUILD_TOP/uv-dist"
    fi
}

# installs the requirements, the overrides and the project's wheel into a new
# virtual environment, passing the other arguments to uv pip install
uvInstall() {
    local venv=$1 requirements=$2
    shift 2

    # shellcheck disable=SC2154
    uv venv --python "$uvPython" "$venv"
    # shellcheck disable=SC2154
    uv pip install --python "$venv/bin/python" --no-index --find-links "$uvWheelIndex" \
        --require-hashes --no-deps --no-build --requirement "$requirements" "$@"

    local override wheels
    # shellcheck disable=SC2154
    for override in $uvOverrides; do
        if [ -d "$override" ]; then
            wheels=("$override"/*.whl)
        else
            wheels=("$override")
        fi
        if [ ! -f "${wheels[0]}" ]; then
            echo "mkUvPackage: no wheel found in $override" >&2
            exit 1
        fi
        uv pip install --python "$venv/bin/python" --no-index --no-deps "${wheels[@]}" "$@"
    done

    if [ -d "$NIX_BUILD_TOP/uv-dist" ]; then
        uv pip install --python "$venv/bin/python" --no-index --no-deps "$NIX_BUILD_TOP"/uv-dist/*.whl "$@"
    fi

    uv pip check --python "$venv/bin/python"
}

# creates the environment for the check phase, with the dependency groups
uvCheckEnv() {
    uvInstall "$NIX_BUILD_TOP/uv-venv" "$NIX_BUILD_TOP/requirements-check.txt"
    # $out is patched in the fixup phase, after the checks
    if declare -F autoPatchelf > /dev/null; then
        autoPatchelf "$NIX_BUILD_TOP/uv-venv"
    fi
    export VIRTUAL_ENV="$NIX_BUILD_TOP/uv-venv"
    export PATH="$VIRTUAL_ENV/bin:$PATH"
}
