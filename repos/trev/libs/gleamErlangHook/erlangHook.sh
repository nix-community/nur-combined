# shellcheck shell=bash disable=SC2154

gleamBuildApp() {
    gleam export erlang-shipment
}

gleamInstallApp() {
    local name="$1"

    mkdir -p "${out}/bin" "${out}/lib"
    cp -a build/erlang-shipment/. "${out}/lib"

    echo "#!@shell@" > "${out}/bin/${name}"
    echo "@erl@ -pa ${out}/lib/*/ebin -eval \"${name}@@main:run(${name})\" -noshell -extra \"\$@\"" >> "${out}/bin/${name}"

    chmod +x "${out}/bin/${name}"
}
