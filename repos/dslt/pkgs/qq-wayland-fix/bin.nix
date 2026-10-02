{
  lib,
  stdenv,
  autoPatchelfHook,
  dpkg,
  bashInteractive,
  glib,
  libx11,
  wayland,
  qq,
  sources,
}:

let
  source = sources.qq-wayland-fix-bin-x86_64;
in
stdenv.mkDerivation {
  pname = "linuxqq-wayland-fix-bin";
  inherit (source) version src;

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];
  buildInputs = [
    glib
    libx11
    stdenv.cc.cc.lib
    wayland
  ];

  dontConfigure = true;
  dontBuild = true;
  # The shims are LD_PRELOAD interposers; keep the symbols as upstream built them.
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/bin/linuxqq-wayland-fix $out/bin/linuxqq-wayland-fix
    install -d $out/lib
    cp -r usr/lib/linuxqq-wayland-fix $out/lib/linuxqq-wayland-fix
    install -Dm644 usr/share/applications/linuxqq-wayland-fix.desktop \
      $out/share/applications/linuxqq-wayland-fix.desktop
    mkdir -p $out/share/doc
    cp -r usr/share/doc/linuxqq-wayland-fix $out/share/doc/linuxqq-wayland-fix
    install -Dm644 usr/share/licenses/linuxqq-wayland-fix/LICENSE \
      $out/share/licenses/linuxqq-wayland-fix/LICENSE

    # The release launcher hardcodes the distro libdir and a distro bash: point
    # LIBDIR at this output, use the interactive bash that provides compgen, and
    # seed QQ_WAYLAND_FIX_QQ with the packaged QQ so it works out of the box
    # (the user's own export still wins).
    substituteInPlace $out/bin/linuxqq-wayland-fix \
      --replace-fail '#!/bin/bash' "#!${lib.getExe bashInteractive}" \
      --replace-fail 'LIBDIR="/usr/lib/linuxqq-wayland-fix"' "LIBDIR=\"$out/lib/linuxqq-wayland-fix\"" \
      --replace-fail 'set -u' 'set -u
: "''${QQ_WAYLAND_FIX_QQ:=${qq}/bin/qq}"'

    # Icon=qq resolves through the session's XDG_DATA_DIRS, which never contains
    # a dependency's share tree; expose QQ's icons from this output.
    ln -s ${qq}/share/icons $out/share/icons

    runHook postInstall
  '';

  meta = {
    description = "LinuxQQ Wayland fix launcher and LD_PRELOAD shims, from the upstream prebuilt release";
    longDescription = ''
      The upstream prebuilt release of linuxqq-wayland-fix: launcher, the four
      compiled LD_PRELOAD shims, the desktop entry ("QQ（Wayland修复版）") and the
      docs, extracted from the release Debian package and patched to run from
      the Nix store. It is the prebuilt counterpart of `qq-wayland-fix-launcher`,
      which compiles the same launcher and shims from the tracked git revision;
      upstream publishes no release containing a patched QQ, so this package
      ships no `qq` wrapper either.

      QQ itself is not part of the release and must be installed separately:
      QQ_WAYLAND_FIX_QQ is seeded with the packaged `qq` wrapper and can still
      be overridden, otherwise the launcher falls back to a `linuxqq` command in
      PATH and /opt/QQ/qq. Upstream publishes no aarch64 asset, so this package
      is x86_64-linux only.
    '';
    homepage = "https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix";
    changelog = "https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix/releases/tag/v${source.version}";
    license = lib.licenses.mit;
    mainProgram = "linuxqq-wayland-fix";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
