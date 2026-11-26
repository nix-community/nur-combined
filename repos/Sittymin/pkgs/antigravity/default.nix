{
  lib,
  stdenv,
  fetchurl,
  asar,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  writeShellScript,
  runCommand,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  chromium,
  cups,
  dbus,
  expat,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  pango,
  pipewire,
  systemdLibs,
  vulkan-loader,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libxcb,
  libxshmfence,
  libxkbfile,
  zlib,
  git,
  xdg-utils,
  browserPkg ? chromium,
  useUserProfile ? true,
  browserProfileDir ? (
    {
      chromium = "$HOME/.config/chromium";
      ungoogled-chromium = "$HOME/.config/chromium";
      google-chrome = "$HOME/.config/google-chrome";
      brave = "$HOME/.config/BraveSoftware/Brave-Browser";
      vivaldi = "$HOME/.config/vivaldi";
    }
    .${lib.getName browserPkg} or "$HOME/.config/chromium"
  ),
}:

let
  version = "2.35.2-4585983447007232";

  sources = {
    x86_64-linux = {
      arch = "linux-x64";
      hash = "sha256-LTPbKCsemzx1gsFA2rnoaEjxs3oFv6Sh3/f0TeG/ME8=";
    };
    aarch64-linux = {
      arch = "linux-arm";
      hash = "sha256-jevgvhGpqJq0ShAjPj/e+46K0ltc7+tY8kV9GNCrkHA=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "antigravity: unsupported system ${stdenv.hostPlatform.system}");

  pname = "antigravity";
  desktopIcon = "antigravity";

  browserExe = lib.getExe browserPkg;
  browserCommand = baseNameOf browserExe;

  browserScript = writeShellScript "google-chrome-stable" ''
    set -euo pipefail

    # Prefer the system browser: it owns the profile and is usually newer than
    # the nixpkgs pin.
    browser_cmd="/run/current-system/sw/bin/${browserCommand}"
    if [ ! -x "$browser_cmd" ]; then
      browser_cmd="${browserExe}"
    fi

    exec "$browser_cmd" \
      ${lib.optionalString useUserProfile ''--user-data-dir="${browserProfileDir}" --profile-directory=Default''} \
      "$@"
  '';

  chrome-wrapper = runCommand "antigravity-browser-wrapper" { } ''
    mkdir -p $out/bin
    ln -s ${browserScript} $out/bin/google-chrome-stable
    ln -s ${browserScript} $out/bin/google-chrome
  '';

  linkDevToolsPort = lib.optionalString useUserProfile ''
    chrome_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/google-chrome"
    if [ "${browserProfileDir}" != "$chrome_dir" ]; then
      port_link="$chrome_dir/DevToolsActivePort"
      if [ -L "$port_link" ] || [ ! -e "$port_link" ]; then
        mkdir -p "$chrome_dir"
        ln -sfn "${browserProfileDir}/DevToolsActivePort" "$port_link"
      else
        echo "antigravity: $port_link is owned by another browser, not linking it to ${browserProfileDir}" >&2
      fi
    fi
  '';

  linkedLibs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libuuid
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
    libxshmfence
    libxkbfile
    zlib
  ];

  dlopenLibs = [
    libglvnd
    vulkan-loader
    systemdLibs
    libnotify
    libsecret
    libpulseaudio
  ];

  desktopItem = makeDesktopItem {
    name = desktopIcon;
    desktopName = "Google Antigravity";
    comment = "Agentic development environment";
    exec = "${desktopIcon} %U";
    icon = desktopIcon;
    categories = [
      "Development"
      "IDE"
    ];
    startupNotify = true;
    startupWMClass = "Antigravity";
    mimeTypes = [ "x-scheme-handler/antigravity" ];
  };

  meta = {
    description = "Google Antigravity";
    homepage = "https://antigravity.google";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
    mainProgram = desktopIcon;
  };
in
stdenv.mkDerivation {
  inherit pname version meta;

  src = fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}/${source.arch}/Antigravity.tar.gz";
    hash = source.hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    asar
  ];

  buildInputs = linkedLibs;

  runtimeDependencies = dlopenLibs;

  autoPatchelfIgnoreMissingDeps = [
    "libwebkit2gtk-4.1.so.0"
    "libsoup-3.0.so.0"
    "libcurl.so.4"
    "libcrypto.so.3"
  ];

  desktopItems = [ desktopItem ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    tar -xzf $src
    for d in *; do
      if [ -d "$d" ]; then
        cd "$d"
        break
      fi
    done
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${pname}
    cp -r ./* $out/lib/${pname}/

    # The app expects a bundled tunnel helper that upstream does not ship.
    mkdir -p $out/lib/${pname}/resources/bin
    cat <<'EOF' > $out/lib/${pname}/resources/bin/antigravity-tunnel
    #!/usr/bin/env bash
    echo "Remote tunneling is not supported in the Linux package of Google Antigravity because the required proprietary binary is not bundled." >&2
    exit 1
    EOF
    chmod +x $out/lib/${pname}/resources/bin/antigravity-tunnel

    cat <<'EOF' > $out/lib/${pname}/launcher.sh
    #!/bin/sh
    bin="$1"
    shift
    ${linkDevToolsPort}
    exec "$bin" "$@"
    EOF
    chmod +x $out/lib/${pname}/launcher.sh

    mkdir -p $out/bin
    makeWrapper $out/lib/${pname}/launcher.sh $out/bin/${desktopIcon} \
      --add-flags $out/lib/${pname}/antigravity \
      --set CHROME_BIN ${chrome-wrapper}/bin/google-chrome-stable \
      --set CHROME_PATH ${chrome-wrapper}/bin/google-chrome-stable \
      --prefix PATH : "${
        lib.makeBinPath [
          chrome-wrapper
          browserPkg
          git
          xdg-utils
        ]
      }" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath dlopenLibs}" \
      --set-default ALSA_PLUGIN_DIR "${pipewire}/lib/alsa-lib" \
      --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}"

    # app.asar.unpacked is referenced by the archive header but a full extract
    # fails when a referenced file is absent; extract just the icon.
    tmp="$(mktemp -d)"
    (
      cd "$tmp"
      asar extract-file "$out/lib/${pname}/resources/app.asar" icon.png
    )
    install -Dm644 "$tmp/icon.png" $out/share/icons/hicolor/512x512/apps/${desktopIcon}.png
    install -Dm644 "$tmp/icon.png" $out/share/pixmaps/${desktopIcon}.png
    rm -rf "$tmp"

    runHook postInstall
  '';
}