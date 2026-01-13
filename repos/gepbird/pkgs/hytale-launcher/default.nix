# NOTE
# this was taken from https://github.com/NixOS/nixpkgs/pull/479368, credits to all people involved
# converting to buildFHSEnv was done by AI, needs cleanup
{
  lib,
  stdenv,
  fetchzip,
  buildFHSEnv,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  writeScript,
  gtk3,
  nss,
  libsecret,
  libsoup_3,
  gdk-pixbuf,
  glib,
  webkitgtk_4_1,
  xdg-utils,
  openssl,
  SDL2,
  xorg,
  wayland,
  libxkbcommon,
  libdecor,
  alsa-lib,
  libpulseaudio,
}:

let
  version = "2026.01.13-e6eb932";

  sources = {
    x86_64-linux = {
      url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-${version}.zip";
      hash = "sha256-GpcyXypBdQpeYRWQjCkqIkzRFAXUjMEZNFPbQjsBEAc=";
    };
    aarch64-darwin = {
      url = "https://launcher.hytale.com/builds/release/darwin/arm64/hytale-launcher-${version}.zip";
      hash = "sha256-emfYJhZj2nNV3Ox3WaR+cHRn4pCyUGaYq0H611s8YHA=";
    };
  };

  currentSource =
    sources.${stdenv.hostPlatform.system}
      or (throw "unsupported system: ${stdenv.hostPlatform.system}");

  pname = "hytale-launcher";

  unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "${pname}-unwrapped";
    inherit version;

    src = fetchzip {
      inherit (currentSource) url hash;
    };

    nativeBuildInputs = [
      makeWrapper
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      copyDesktopItems
    ];

    desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
      (makeDesktopItem {
        name = "hytale-launcher";
        exec = "hytale-launcher";
        desktopName = "Hytale Launcher";
        categories = [ "Game" ];
        terminal = false;
      })
    ];

    dontStrip = true;

    installPhase = ''
      runHook preInstall
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p "$out/bin"
      install -Dm755 "hytale-launcher" "$out/bin/hytale-launcher"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/Applications" "$out/bin"
      cp -r hytale-launcher.app "$out/Applications/"
      makeWrapper "$out/Applications/hytale-launcher.app/Contents/MacOS/hytale-launcher" "$out/bin/hytale-launcher"
    ''
    + ''
      runHook postInstall
    '';

    meta = {
      description = "Official launcher for Hytale";
      homepage = "https://hytale.com";
      license = lib.licenses.unfreeRedistributable;
      maintainers = with lib.maintainers; [ gepbird ];
      mainProgram = "hytale-launcher";
      platforms = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  });
in
if stdenv.hostPlatform.isLinux then
  buildFHSEnv {
    name = pname;
    inherit version;

    targetPkgs =
      pkgs:
      (with pkgs; [
        unwrapped
        gtk3
        nss
        libsecret
        libsoup_3
        gdk-pixbuf
        glib
        webkitgtk_4_1
        xdg-utils
        mesa
        libglvnd
        libdrm
        icu
        openssl
        SDL2
        xorg.libX11
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXext
        xorg.libXi
        xorg.libXinerama
        xorg.libXxf86vm
        wayland
        libxkbcommon
        libdecor
        alsa-lib
        libpulseaudio
      ]);

    profile = ''
      export WEBKIT_DISABLE_DMABUF_RENDERER=1
      export __NV_DISABLE_EXPLICIT_SYNC=1
    '';

    runScript = "hytale-launcher";

    extraInstallCommands = ''
      mkdir -p "$out/share/applications"
      ln -s "${unwrapped}/share/applications/hytale-launcher.desktop" "$out/share/applications/"
    '';

    inherit (unwrapped) meta;

    passthru.updateScript =
      writeScript "update-hytale-launcher" # sh
        ''
          #!/usr/bin/env nix-shell
          #!nix-shell --pure -i bash -p bash curl cacert jq nix common-updater-scripts

          set -euo pipefail

          launcherJson=$(curl -s https://launcher.hytale.com/version/release/launcher.json)

          launcherJq() {
            echo "$launcherJson" | jq --raw-output "$1"
          }

          latestVersion="$(launcherJq '.version')"
          currentVersion="$(NIXPKGS_ALLOW_UNFREE=1 nix eval --impure --raw -f . ${pname}.version)"

          if [[ "$latestVersion" == "$currentVersion" ]]; then
            echo "package is up-to-date"
            exit 0
          fi

          update() {
            system="$1"
            url="$2"
            # TODO: fix hash, this differs from what fetchzip creates
            prefetched="$(nix-prefetch-url --unpack "$url")"
            hash="$(nix-hash --type sha256 --to-sri "$prefetched")"
            update-source-version --system="$system" --ignore-same-version ${pname} "$latestVersion" "$hash"
          }

          update "x86_64-linux" "$(launcherJq ".download_url.linux.amd64.url")"
          update "aarch64-darwin" "$(launcherJq ".download_url.darwin.arm64.url")"
        '';
  }
else
  unwrapped.overrideAttrs (old: {
    pname = pname;
  })
