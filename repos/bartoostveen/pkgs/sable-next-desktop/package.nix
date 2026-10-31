{
  lib,
  pkgs,
  callPackage,
  sable-next,
  pkg-config,
  wrapGAppsHook3,
  makeBinaryWrapper,
  makeDesktopItem,
  copyDesktopItems,
  stdenv,
  desktop-file-utils,
  pnpm_12,
  nodejs_26,
  pnpmConfigHook,
  pnpmBuildHook,
  rustPlatform,
  electron_45 ?
    # TODO: remove once either https://github.com/NixOS/nixpkgs/pull/578912 gets merged or electron_45-src gets initialized
    callPackage "${pkgs.path}/pkgs/development/tools/electron/binary/generic.nix" { } "45.0.0" {
      aarch64-darwin = "896c3a50b148e89a158dca08a6996a022ddf39b23aac871e107f5b4087f8caa9";
      aarch64-linux = "a80d92b1ad6c111545a12632b8a75cedce614a41866e500810d4050d947f90e9";
      headers = "1xwf0ph68l3479v11n2rfzgyg8rfwi81whb10ngbalsc1v2jy68s";
      x86_64-linux = "22f6a10bd3f7fef987ddbb379d3375ce664ad0c98a9a50f80c89f1718a0c3e3a";
    },
  atk,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gtk3,
  libsoup_3,
  pango,
  pipewire,
  sqlite,
  wayland,
  webkitgtk_4_1,
  zstd,
  conf ? { },
}:

let
  pnpm = pnpm_12;
  nodejs = nodejs_26;
  electron = electron_45;
  sable' = sable-next.override { inherit conf; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-next-desktop";
  inherit (sable-next.unwrapped)
    version
    src
    patches
    cargoDeps
    pnpmDeps
    ;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpmBuildHook
    pnpm

    rustPlatform.rust.rustc
    rustPlatform.rust.cargo
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook

    desktop-file-utils
    makeBinaryWrapper
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    atk
    cairo
    dbus
    gdk-pixbuf
    glib
    gtk3
    libsoup_3
    pango
    pipewire
    sqlite
    webkitgtk_4_1
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
  ];

  env = {
    LIBSQLITE3_SYS_USE_PKG_CONFIG = true;
    SABLE_BUILD_FLAVOR = "stable";
    VERSION = finalAttrs.version;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  buildPhase = ''
    runHook preBuild

    cp --no-preserve=all -r ${sable'} dist

    mkdir -p electron-dist
    cp -rL --no-preserve=all ${electron_45.dist}/. electron-dist/
    chmod -R u+w electron-dist

    pnpm --dir electron package --dir \
      ${
        if stdenv.hostPlatform.isLinux then
          "--linux"
        else if stdenv.hostPlatform.isDarwin then
          "--mac"
        else
          throw "Platform not supported"
      } \
      -c.electronDist="../electron-dist" \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/lib/sable-next/dist"
    cp -r electron/release/*-unpacked/resources/app.asar* "$out/share/lib/sable-next/"
    cp -r dist/. "$out/share/lib/sable-next/dist/"

    install -m 444 -D src-tauri/icons/icon.png $out/share/icons/hicolor/512x512/apps/sable-next.png
    install -m 444 -D src-tauri/icons/icon.png $out/share/lib/sable-next/src-tauri/icons/icon.png

    makeBinaryWrapper '${lib.getExe electron}' "$out/bin/sable-next" \
      --add-flags "$out/share/lib/sable-next/app.asar" \
      --inherit-argv0

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/bin"
      makeWrapper "$out/Applications/SableNext.app/Contents/MacOS/SableNext" "$out/bin/sable-next"
    ''}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "sable-next";
      exec = "sable-next";
      icon = "sable-next";
      desktopName = "Sable Next";
      comment = finalAttrs.meta.description;
      categories = [
        "Chat"
        "Network"
        "InstantMessaging"
      ];
      startupWMClass = "sable-next";
      terminal = false;
    })
  ];

  meta = {
    inherit (sable-next.meta)
      description
      homepage
      changelog
      license
      maintainers
      ;

    mainProgram = "sable-next";
  };
})
