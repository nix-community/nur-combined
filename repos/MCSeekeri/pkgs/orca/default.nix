{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  gobject-introspection,
  python3,

  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  libxcb,
  libxkbcommon,
  libxshmfence,
  librsvg,
  nspr,
  nss,
  pango,
  pipewire,
  systemdLibs,
  wayland,
  libayatana-appindicator,
  adwaita-icon-theme,
  gsettings-desktop-schemas,

  coreutils,
  git,
  openssh,
  which,
  wl-clipboard,
  xclip,
  xsel,
  xdotool,
  xdg-utils,
  xvfb,
  xvfb-run,
}:

let
  version = "1.4.262";

  dlopenLibraries = [
    libGL
    libx11
    libxtst
  ];

  computerUsePython = python3.withPackages (ps: [ ps.pygobject3 ]);

  runtimeTools = [
    coreutils
    git
    openssh
    python3
    which
    wl-clipboard
    xclip
    xsel
    xdg-utils
    xdotool
    xvfb
    xvfb-run
  ];
in
stdenv.mkDerivation {
  pname = "orca";
  inherit version;

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-ide_${version}_${
      if stdenv.hostPlatform.isAarch64 then "arm64" else "amd64"
    }.deb";
    hash =
      if stdenv.hostPlatform.isAarch64 then
        "sha256-D8bFf65//QKvykaZ7w14u1na4YGu2Nigm6+C3Uen0rU="
      else
        "sha256-9v7DXTE4tkshUen2z6W28XxyUgYNEENQ1C3ZRb0DO0M=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    adwaita-icon-theme
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gsettings-desktop-schemas
    gtk3
    libdrm
    libgbm
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    librsvg
    libxcb
    libxkbcommon
    libxshmfence
    nspr
    nss
    pango
    systemdLibs
    stdenv.cc.cc.lib
  ];

  runtimeDependencies = [
    libayatana-appindicator
    libnotify
    libpulseaudio
    libsecret
    libuuid
    libxcursor
    libxi
    libxrender
    libxscrnsaver
    libxtst
    pipewire
    wayland
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  dontBuild = true;
  dontWrapGApps = true;
  dontStrip = true;
  dontAutoPatchelf = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share
    cp -a opt/Orca $out/lib/Orca
    cp -a usr/share/icons $out/share/icons
    install -Dm644 usr/share/applications/orca-ide.desktop $out/share/applications/orca-ide.desktop
    substituteInPlace $out/share/applications/orca-ide.desktop \
      --replace-fail "/opt/Orca/orca-ide" "orca-ide"

    rm -f $out/lib/Orca/chrome-sandbox
    chmod +x $out/lib/Orca/orca-ide $out/lib/Orca/resources/bin/orca-ide
    patchShebangs $out/lib/Orca/resources/bin/orca-ide

    mkdir -p "$out/libexec"
    cat > "$out/libexec/orca-computer-use.py" <<EOF
    import os
    import sys
    os.execv("$out/libexec/orca-computer-use-python", ["$out/libexec/orca-computer-use-python", *sys.argv[1:]])
    EOF
    chmod +x "$out/libexec/orca-computer-use.py"

    cat > "$out/libexec/orca-ide-launcher" <<'LAUNCHER'
    #!${stdenv.shell}
    set -euo pipefail

    args=()
    store=''${ORCA_PASSWORD_STORE:-}

    if [[ -z $store ]]; then
      case ''${XDG_CURRENT_DESKTOP:-} in
        *GNOME* | *Unity* | *Pantheon* | *XFCE* | *KDE* | *Plasma* | *Cinnamon* | *MATE* | *Budgie*) ;;
        *)
          runtime_dir=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          if [[ -S $runtime_dir/keyring/control ]]; then
            store=gnome-libsecret
          fi
          ;;
      esac
    fi

    if [[ -n $store ]]; then
      args+=("--password-store=$store")
    fi

    exec "@out@/lib/Orca/orca-ide" "''${args[@]}" "$@"
    LAUNCHER
    substituteInPlace "$out/libexec/orca-ide-launcher" --subst-var out
    chmod +x "$out/libexec/orca-ide-launcher"

    runHook postInstall
  '';

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  postFixup = ''
    autoPatchelf \
      $(find "$out/lib/Orca" -mindepth 1 -maxdepth 1 ! -name resources) \
      $(find "$out/lib/Orca/resources" -mindepth 1 -maxdepth 1 ! -name orcad-template)

    makeWrapper "${lib.getExe computerUsePython}" "$out/libexec/orca-computer-use-python" \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "$out/lib/Orca/resources/computer-use-linux/runtime.py" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath dlopenLibraries}"

    launcherArgs=(
      "''${gappsWrapperArgs[@]}"
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
      --set-default ORCA_COMPUTER_DESKTOP_SCRIPT_PROVIDER_PATH "$out/libexec/orca-computer-use.py"
      --suffix PATH : "${lib.makeBinPath runtimeTools}"
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath dlopenLibraries}"
    )
    makeWrapper "$out/libexec/orca-ide-launcher" "$out/bin/orca-ide" "''${launcherArgs[@]}"
    wrapProgram "$out/lib/Orca/resources/bin/orca-ide" "''${launcherArgs[@]}"
    ln -s "$out/lib/Orca/resources/bin/orca-ide" "$out/bin/orca"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR"
    "$out/bin/orca" --version | grep -F "${version}"

    makeWrapper "${lib.getExe computerUsePython}" "$TMPDIR/check-python" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath dlopenLibraries}"
    "$TMPDIR/check-python" <<'EOF'
    import ctypes
    import gi

    gi.require_version("Atspi", "2.0")
    gi.require_version("Gdk", "3.0")
    gi.require_version("GdkPixbuf", "2.0")
    from gi.repository import Atspi, Gdk, GdkPixbuf

    ctypes.CDLL("libX11.so.6")
    ctypes.CDLL("libXtst.so.6")
    EOF
  '';

  meta = {
    description = "ADE for working with a fleet of parallel coding agents";
    homepage = "https://onorca.dev";
    changelog = "https://github.com/stablyai/orca/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "orca-ide";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
