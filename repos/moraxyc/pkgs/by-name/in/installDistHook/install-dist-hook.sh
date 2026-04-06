# shellcheck shell=bash disable=SC2206

installDistHook() {
    echo "Executing installDistHook"

    runHook preInstall

    local distDir="${installDistDir:-dist}"

    echo "installDistPhase: Installing distribution artifacts from '$distDir' to '$out'..."

    if [ ! -d "$distDir" ]; then
        echo "installDistPhase: Error: Source directory '$distDir' does not exist."
        echo "Please ensure the build phase generates this directory, or set \$installDistDir."
        exit 1
    fi

    mkdir -p "$out"
    cp -rT "$distDir" "$out"

    runHook postInstall

    echo "Finished installDistHook"
}

if [ -z "${installPhase-}" ]; then
    installPhase=installDistHook
fi
