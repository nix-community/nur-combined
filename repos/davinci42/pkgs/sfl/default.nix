{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  autoPatchelfHook,
  wrapGAppsHook3,
  zstd,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  gtk4,
  libappindicator-gtk3,
  libdbusmenu,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxshmfence,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  speechd-minimal,
  systemd,
  vulkan-loader,
  wayland,
  xdg-utils,
  xprop,
  xrdb,
  writeShellApplication,
  python3,
  nix-update,
  nix,
  gh,
}:
let
  sources = {
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-0yk9l/zIYFhpYkQgdQxWXwiCiO7VJVYcOv9g9Mg6kvY=";
    };
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-phlP3FXC3rwea8ng2d51YcchPXqPc3NLZ/08HGxXXww=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
  runtimeLibraries = [
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
    libappindicator-gtk3
    libdbusmenu
    libdrm
    libgbm
    libGL
    libnotify
    libpulseaudio
    libsecret
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxkbfile
    libxrandr
    libxshmfence
    nspr
    nss
    pango
    pciutils
    pipewire
    speechd-minimal
    stdenv.cc.cc
    systemd
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sfl";
  version = "1.15.0-alpha.12";

  src = fetchurl {
    url = "https://github.com/SagerNet/sing-box/releases/download/v${finalAttrs.version}/SFL-${finalAttrs.version}-${source.arch}.pkg.tar.zst";
    inherit (source) hash;
  };

  sourceRoot = ".";
  dontBuild = true;
  dontStrip = true;
  dontWrapGApps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    zstd
  ];

  buildInputs = runtimeLibraries;
  runtimeDependencies = runtimeLibraries;

  unpackPhase = ''
    runHook preUnpack
    tar --zstd -xf "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/opt" "$out/lib/systemd/system" "$out/share"
    cp -r opt/sing-box "$out/opt/sing-box"
    cp -r usr/share/* "$out/share/"
    cp usr/lib/systemd/system/sing-box-daemon.service "$out/lib/systemd/system/sing-box-daemon.service"

    substituteInPlace "$out/share/applications/sing-box.desktop" \
      --replace-fail "Exec=/opt/sing-box/sing-box %U" "Exec=$out/bin/sfl %U"
    substituteInPlace "$out/share/metainfo/io.nekohasekai.sfl.metainfo.xml" \
      --replace-fail "<binary>sing-box</binary>" "<binary>sfl</binary>"
    substituteInPlace "$out/lib/systemd/system/sing-box-daemon.service" \
      --replace-fail "/opt/sing-box/resources/daemon/sing-box-daemon" "$out/bin/sing-box-daemon"

    ln -s "$out/opt/sing-box/resources/daemon/sing-box-daemon" "$out/bin/sing-box-daemon"
    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "$out/opt/sing-box/sing-box" "$out/bin/sfl" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : "${
        lib.makeBinPath [
          xdg-utils
          xprop
          xrdb
        ]
      }"
  '';

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-sfl";
      runtimeInputs = [
        python3
        nix-update
        nix
        gh
      ];
      text = ''
        exec python3 pkgs/sfl/update.py "$@"
      '';
    });
    tests.packaging = callPackage ../../tests/pkgs/sfl.nix {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Linux desktop client for sing-box";
    homepage = "https://github.com/SagerNet/sing-box-for-desktop";
    changelog = "https://github.com/SagerNet/sing-box/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "sfl";
  };
})
