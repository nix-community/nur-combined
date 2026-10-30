# shellcheck shell=bash disable=SC2154

gleamBuildApp() {
    gleam build --target javascript
}

gleamInstallApp() {
    local name="$1"

    mkdir -p "${out}/bin" "${out}/lib"
    cp -a build/dev/javascript/. "${out}/lib"

    cat <<EOF > "${out}/lib/${name}/main.mjs"
import { main } from "./${name}.mjs";
main();
EOF

    cat <<EOF > "${out}/bin/${name}"
#!@shell@
@nodejs@ "${out}/lib/${name}/main.mjs" "\$@"
EOF

    chmod +x "${out}/bin/${name}"
}
