# Copied from nixpkgs pkgs/development/tools/electron/binary/generic.nix
# at commit 4fb0462eccd53802e61d6b0dc70e7d98cc06d167 (last commit before removal
# by "electron_36-bin, electron-chromedriver_36: remove", 2026-01-29).
# electron_36-bin was removed from nixpkgs on 2026-02-02 in favor of newer
# versions. We preserve it here because EasyEDA Pro ships with Electron 36.
{
  lib,
  stdenv,
  makeWrapper,
  fetchurl,
  fetchzip,
  wrapGAppsHook3,
  glib,
  gtk3,
  gtk4,
  unzip,
  at-spi2-atk,
  libdrm,
  libgbm,
  libxkbcommon,
  libxshmfence,
  libGL,
  vulkan-loader,
  alsa-lib,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  nss,
  nspr,
  libxrandr,
  libxfixes,
  libxext,
  libxdamage,
  libxcomposite,
  libx11,
  libxkbfile,
  libxcb,
  pango,
  systemd,
  pciutils,
  libnotify,
  pipewire,
  libsecret,
  libpulseaudio,
  speechd-minimal,
}:

let
  version = "36.9.5";

  hashes = {
    x86_64-linux = "sha256-UtY2Su7WgRYyD4zW99e2rRhdoBH/ISdV8YxgRpZihhY=";
    aarch64-linux = "sha256-9+mjB58idrkHw54LrQ3tCNaEYnSCPUNxJWqC56R/qyc=";
    headers = "sha256-bRXDTx9j1z5rJRJx8Gk887UUclb8GLShWMuSvgAsyho=";
  };

  tags = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
  };

  src = fetchurl {
    url = "https://github.com/electron/electron/releases/download/v${version}/electron-v${version}-${tags.${stdenv.hostPlatform.system} or (throw "electron_36-bin: unsupported system ${stdenv.hostPlatform.system}")}.zip";
    hash = hashes.${stdenv.hostPlatform.system} or (throw "electron_36-bin: unsupported system ${stdenv.hostPlatform.system}");
  };

  headers = fetchzip {
    name = "electron-${version}-headers";
    url = "https://artifacts.electronjs.org/headers/dist/v${version}/node-v${version}-headers.tar.gz";
    hash = hashes.headers;
    stripRoot = false;
  };

  electronLibPath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    gtk4
    nss
    nspr
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxkbfile
    pango
    pciutils
    stdenv.cc.cc
    systemd
    libnotify
    pipewire
    libsecret
    libpulseaudio
    speechd-minimal
    libdrm
    libgbm
    libxkbcommon
    libxshmfence
    libGL
    vulkan-loader
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "electron";
  inherit version src;

  buildInputs = [
    glib
    gtk3
    gtk4
  ];

  nativeBuildInputs = [
    unzip
    makeWrapper
    wrapGAppsHook3
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/libexec/electron
    unzip -d $out/libexec/electron $src
    chmod u-x $out/libexec/electron/*.so*
  '';

  # We don't want to wrap the contents of $out/libexec automatically
  dontWrapGApps = true;

  preFixup = ''
    makeWrapper "$out/libexec/electron/electron" $out/bin/electron \
      "''${gappsWrapperArgs[@]}"
  '';

  postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${electronLibPath}:$out/libexec/electron" \
      $out/libexec/electron/electron \
      $out/libexec/electron/chrome_crashpad_handler

    # patch libANGLE
    patchelf \
      --set-rpath "${lib.makeLibraryPath [ libGL pciutils vulkan-loader ]}" \
      $out/libexec/electron/lib*GL*

    # replace bundled vulkan-loader
    rm "$out/libexec/electron/libvulkan.so.1"
    ln -s -t "$out/libexec/electron" "${lib.getLib vulkan-loader}/lib/libvulkan.so.1"
  '';

  passthru = {
    dist = finalAttrs.finalPackage + "/libexec/electron";
    inherit headers;
  };

  meta = {
    description = "Cross platform desktop application shell (Electron 36)";
    homepage = "https://github.com/electron/electron";
    changelog = "https://github.com/electron/electron/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "electron";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    knownVulnerabilities = [ "Electron 36 is EOL — use only for apps that require this specific ABI (e.g. EasyEDA Pro)" ];
  };
})
