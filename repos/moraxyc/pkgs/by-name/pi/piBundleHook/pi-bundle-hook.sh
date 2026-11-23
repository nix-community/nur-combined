# shellcheck shell=bash

_piBundleAppendList() {
    local varName="$1"
    local -n outRef="$2"
    if declare -p "$varName" 2>/dev/null | grep -q '^declare -a'; then
        local -n arrRef="$varName"
        outRef+=("${arrRef[@]}")
    elif [ -n "${!varName-}" ]; then
        local item
        for item in ${!varName}; do
            outRef+=("$item")
        done
    fi
}

piBundleHook() {
    if [ -n "${dontPiBundle-}" ]; then
        return 0
    fi

    echo "Executing piBundleHook"

    local pkg="${piBundleRoot:-$out/lib/${pname}}"
    local srcDir="${piBundleSrcDir:-$pkg}"
    local outDir="${piBundleOutDir:-dist}"
    local format="${piBundleFormat:-esm}"
    local minify="${piBundleMinify:-1}"
    local keepSources="${piBundleKeepSources:-0}"
    local keepNodeModules="${piBundleKeepNodeModules:-0}"

    local -a entries=()
    local -a esbuildFlags=()
    local -a cleanPaths=()
    _piBundleAppendList piBundleEntries entries
    _piBundleAppendList piBundleEsbuildFlags esbuildFlags
    _piBundleAppendList piBundleCleanPaths cleanPaths

    node @bundleScript@ "@nodeMajor@" \
        "$pkg" "$srcDir" "$outDir" "$format" "$minify" "$keepSources" "$keepNodeModules" \
        "${#entries[@]}" "${entries[@]}" \
        "${#esbuildFlags[@]}" "${esbuildFlags[@]}" \
        "${#cleanPaths[@]}" "${cleanPaths[@]}"

    if [ "$keepNodeModules" = "1" ] && [ -d "$pkg/node_modules" ]; then
        { grep -rlI '^#!/nix/store/' "$pkg/node_modules" || true; } \
            | xargs -r sed -i '1s|^#!/nix/store/[^/]*/bin/node$|#!/usr/bin/env node|'
    fi

    echo "Finished piBundleHook"
}

postInstallHooks+=(piBundleHook)
