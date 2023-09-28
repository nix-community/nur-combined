{ config, lib, pkgs, ... }:

# Don't forget to add firefoxpwa
# to extraNativePackagesMessagingHosts in firefox
#  pkgs.firefox.override {
#    extraNativeMessagingHosts = [
#      firefoxpwa
#    ];
#  };
#
# or use the overlays:
# rutherther.overlays.firefoxpwa
# rutherther.overlays.firefox-native-messaging

pkgs.rustPlatform.buildRustPackage rec {
    pname = "firefoxpwa";
    version = "2.7.3";

    src = pkgs.fetchFromGitHub {
      owner = "filips123";
      repo = "PWAsForFirefox";
      rev = "v${version}";
      hash = "sha256-G1szjwQwlidtUaJZb1KdlkSXfgTIM26ZVj4Fn5VEZgQ=";
    } + "/native";

    patchPhase = ''
      sed -i "s|/usr|$out/usr|" manifests/linux.json
      sed -i "s|/usr|$out/usr|" src/directories.rs

      patch < ${./Cargo.toml.patch}
      patch < ${./Cargo.lock.patch}
    '';

    cargoPatches = [
      ./Cargo.lock.patch
      ./Cargo.toml.patch
    ];

    installPhase = ''
      mkdir -p $out/usr/bin $out/bin
      cp target/x86_64-unknown-linux-gnu/release/firefoxpwa $out/bin/

      ln -s $out/bin $out/usr/bin

      mkdir -p $out/usr/libexec
      cp target/x86_64-unknown-linux-gnu/release/firefoxpwa-connector $out/usr/libexec/

      mkdir -p $out/lib/mozilla/native-messaging-hosts
      cp manifests/linux.json $out/lib/mozilla/native-messaging-hosts/firefoxpwa.json

      mkdir -p $out/usr/local/share/firefoxpwa/userchrome
      cp -r userchrome/* $out/usr/local/share/firefoxpwa/userchrome

      mkdir -p $out/usr
      ln -s $out/usr/local/share $out/usr/share
    '';

    cargoLock = let
      fixupLockFile = path: (builtins.readFile path);
    in {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "data-url-0.3.0" = "sha256-SDOOwwvZrX4i04NElBJe5NRS9MXCgRVhBz7L4G8B4m8=";
        "mime-0.4.0-a.0" = "sha256-LjM7LH6rL3moCKxVsA+RUL9lfnvY31IrqHa9pDIAZNE=";
        "web_app_manifest-0.0.0" = "sha256-G+kRN8AEmAY1TxykhLmgoX8TG8y2lrv7SCRJlNy0QzA=";
      };
    };

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.bzip2 pkgs.openssl ];
}
