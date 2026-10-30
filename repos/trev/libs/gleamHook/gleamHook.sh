# shellcheck shell=bash disable=SC2154

# Shared by gleamErlangHook and gleamJavascriptHook, which append the
# functions that build and install an app for their target, gleamBuildApp and
# gleamInstallApp.

gleamConfigHook() {
    echo "Executing gleamConfigHook"

    pushd "${gleamRoot:-.}" || exit 1

    if [ -z "${gleamDeps-}" ]; then
      echo "Error: 'gleamDeps' must be set when using gleamConfigHook."
      exit 1
    fi

    # gleam build, gleam test and gleam check compile rebar3 dependencies,
    # which writes to HOME and the rebar3 cache
    if [ ! -w "${HOME-}" ]; then
      HOME=$(mktemp -d)
      export HOME
    fi
    export REBAR_CACHE_DIR="${REBAR_CACHE_DIR:-${TMPDIR}/.rebar-cache}"

    echo "Configuring gleam cache"

    cp -Tr "${gleamDeps}" build
    chmod -R +w build

    echo "Installing dependencies"

    if ! gleam deps download
    then
        echo
        echo "ERROR: gleam failed to install dependencies"
        echo

        exit 1
    fi

    popd || exit 1

    echo "Finished gleamConfigHook"
}

gleamBuildPhase() {
    runHook preBuild

    echo "Executing gleamBuildPhase"

    pushd "${gleamRoot:-.}" || exit 1

    if [ -n "${gleamLibrary-}" ]; then
      gleam build --target @gleamTarget@
      gleam docs build --target @gleamTarget@
    else
      gleamBuildApp
    fi

    popd || exit 1

    echo "Finished gleamBuildPhase"

    runHook postBuild
}

gleamCheckPhase() {
    runHook preCheck

    echo "Executing gleamCheckPhase"

    pushd "${gleamRoot:-.}" || exit 1

    local name
    name=$(tq -f gleam.toml -r 'name')

    # gleam test fails without the test module
    if [ -f "test/${name}_test.gleam" ]; then
      gleam test --target @gleamTarget@
    else
      echo "test/${name}_test.gleam not found, skipping gleam test"
    fi

    popd || exit 1

    echo "Finished gleamCheckPhase"

    runHook postCheck
}

gleamInstallPhase() {
    runHook preInstall

    echo "Executing gleamInstallPhase"

    pushd "${gleamRoot:-.}" || exit 1

    local name
    name=$(tq -f gleam.toml -r 'name')

    if [ -n "${gleamLibrary-}" ]; then
      mkdir -p "${out}"
      cp -a "build/dev/docs/${name}/." "${out}"
    else
      gleamInstallApp "${name}"
    fi

    popd || exit 1

    echo "Finished gleamInstallPhase"

    runHook postInstall
}

postConfigureHooks+=(gleamConfigHook)

if [ -z "${dontUseGleamBuild-}" ] && [ -z "${buildPhase-}" ]; then
    buildPhase=gleamBuildPhase
fi

if [ -z "${dontUseGleamCheck-}" ] && [ -z "${checkPhase-}" ]; then
    checkPhase=gleamCheckPhase
fi

if [ -z "${dontUseGleamInstall-}" ] && [ -z "${installPhase-}" ]; then
    installPhase=gleamInstallPhase
fi
