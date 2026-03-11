# shellcheck shell=bash disable=SC2154

gleamConfigHook() {
    echo "Executing gleamConfigHook"

    if [ -n "${gleamRoot-}" ]; then
      pushd "$gleamRoot" || exit 1
    fi

    if [ -z "${gleamDeps-}" ]; then
      echo "Error: 'gleamDeps' must be set when using gleamConfigHook."
      exit 1
    fi

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

    if [ -n "${gleamRoot-}" ]; then
      popd || exit 1
    fi

    echo "Finished gleamConfigHook"
}

gleamBuildHook() {
    echo "Executing gleamBuildHook"

    gleam build --target javascript

    echo "Finished gleamBuildHook"
}

gleamInstallHook() {
    echo "Executing gleamInstallHook"

    mkdir -p "${out}/bin" "${out}/lib"
    cp -a build/dev/javascript/. "${out}/lib"

    name=$(tq -f gleam.toml -r 'name')

    cat <<EOF > "${out}/lib/${name}/main.mjs"
import { main } from "./${name}.mjs";
main();
EOF

    cat <<EOF > "${out}/bin/${name}"
#!@shell@
@nodejs@ "${out}/lib/${name}/main.mjs" "\$@"
EOF

    chmod +x "${out}/bin/${name}"

    echo "Finished gleamInstallHook"
}

postConfigureHooks+=(gleamConfigHook)
postBuildHooks+=(gleamBuildHook)
postInstallHooks+=(gleamInstallHook)
