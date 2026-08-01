{ lib }:

let
  firmware = lib.sourceTypes.binaryFirmware;
  hasName = names: pkg: lib.elem (lib.getName pkg) names;

  binaryUnfreePackages = [
    "caido-desktop"
    "claude-code"
    "cursor"
    "cursor-with-keyring"
    "cursor-cli"
    "jetbrains-toolbox"
    "mongodb-compass"
    "ngrok"
    "postman"
    "reaper"
    "zoom"
  ];

  nonSourcePackages = binaryUnfreePackages ++ [
    # Apps
    "alt-tab-macos"
    "beekeeper-studio"
    "brave"
    "bun"
    "ghostty-bin"
    "iina"
    "libreoffice"
    "proton-ge-bin"
    "protonup-qt"

    # Dependencies
    "ant" # libreoffice build dependency
    "cargo-bootstrap" # dependency of nixfmt-tree
    "dart" # bitwarden-desktop -> dart-sass -> dart
    "electron" # bitwarden-desktop uses the binary electron runtime
    "ghc-binary" # dependency of nixfmt-tree
    "go" # bootstrap dependency of nixfmt-tree
    "gradle" # libreoffice -> rhino -> gradle
    "librusty_v8" # codex Rust/V8 archive
    "nvidia-x11" # Goliath NVIDIA driver
    "rustc-bootstrap" # dependency of nixfmt-tree
    "rustc-bootstrap-wrapper" # dependency of nixfmt-tree
    "temurin-bin" # libreoffice -> openjdk -> temurin-bin on Linux
    "zulu-ca-jdk" # libreoffice-bin JDK dependency on Darwin
  ];

  unfreePackages = binaryUnfreePackages ++ [
    # Apps
    "aseprite"
    "kuyen-icons"
    "nvidia-settings"
    "steam"
    "steam-unwrapped"
    "vscode"
    "vscode-extension-bmewburn-vscode-intelephense-client"

    # Dependencies
  ];

  sourceProvenanceOf = pkg: lib.toList (pkg.meta.sourceProvenance or [ ]);
in
{
  allowNonSource = false;
  allowNonSourcePredicate =
    pkg:
    hasName nonSourcePackages pkg
    || lib.all (provenance: (provenance.isSource or false) || provenance == firmware) (
      sourceProvenanceOf pkg
    );

  allowUnfreePredicate =
    pkg: hasName unfreePackages pkg || lib.elem firmware (sourceProvenanceOf pkg);

  allowAliases = true;
  checkMeta = true;
  permittedInsecurePackages = [
    "electron-39.8.10" # bitwarden-desktop
  ];
}
