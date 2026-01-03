# shellcheck shell=bash

# Setup hook that installs specified desktop icons.
#
# Example usage in a derivation:
#
#   { …, makeDesktopIcon, copyDesktopIcons, … }:
#
#   let icon = makeDesktopIcon { … }; in
#   stdenv.mkDerivation {
#     …
#     nativeBuildInputs = [ copyDesktopIcons ];
#
#     desktopIcon = icon;
#     …
#   }

postInstallHooks+=(copyDesktopIcons)

copyDesktopIcons() {
    if [ -z "$desktopIcon" ]; then
        return
    fi

    mkdir -p $out/share/icons
    ln -s ${desktopIcon}/hicolor $out/share/icons
}
