# Ghostex (https://github.com/maddada/Ghostex).
#
# Upstream publishes prebuilt per-platform artifacts (there is no nixpkgs
# package), so this derivation repackages them:
# - aarch64-darwin: arm64 dmg → Ghostex.app in $out/Applications
# - x86_64-linux: tarball → FHS-style $out/opt/ghostex tree with wrappers in
#   $out/bin and a rewritten desktop entry + icon in $out/share
#
# Upstream ships no darwin-x64 dmg and no linux-arm64 desktop build, so those
# systems throw (see `source` below). Refresh versions.json with
# `bun ./update.ts` in this directory.
{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  zstd,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  mesa,
  nspr,
  nss,
  pango,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxkbcommon,
  libxshmfence,
  ...
}:
let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  version = versions.version;
  source =
    versions.${stdenv.hostPlatform.system}
      or (throw "ghostex is not packaged for ${stdenv.hostPlatform.system}: upstream only ships aarch64-darwin and x86_64-linux artifacts");
  src = fetchurl {
    url = "https://github.com/maddada/Ghostex/releases/download/v${version}/${source.file}";
    hash = source.hash;
  };

  # Runtime closure for the Linux GUI, taken from the upstream .deb Depends
  # (CEF/Chromium-style native app). autoPatchelfHook bakes these into RPATH;
  # the makeWrapper LD_LIBRARY_PATH prefix additionally covers dlopen()ed libs
  # and the libcef.so that Ghostex downloads on first launch (it is not part
  # of the release artifacts, hence autoPatchelfIgnoreMissingDeps below).
  linuxLibs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    gdk-pixbuf
    glib
    gtk3
    libdrm
    mesa
    nspr
    nss
    pango
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxkbcommon
    libxshmfence
  ];
in
stdenv.mkDerivation {
  pname = "ghostex";
  inherit version src;

  # The dmg is extracted directly into $out/Applications in installPhase,
  # so the default unpackPhase only runs for the Linux tarball.
  dontUnpack = stdenv.hostPlatform.isDarwin;
  sourceRoot = ".";

  # Stripping would invalidate the app's code signature.
  dontStrip = stdenv.hostPlatform.isDarwin;

  # Note: undmg cannot be used for the dmg — it only supports HFS file
  # systems, while upstream ships an APFS image. _7zz extracts it fine.
  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isDarwin [ _7zz ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
      makeWrapper
      zstd
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux linuxLibs;

  # libcef.so is fetched by Ghostex itself on first launch (shared Chromium
  # runtime), so it cannot be resolved at build time.
  autoPatchelfIgnoreMissingDeps = [ "libcef.so" ];

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        runHook preInstall

        mkdir -p $out/Applications $out/bin
        7zz x -o"$out/Applications" "$src" -y > /dev/null
        # Drop dmg filler (the `Applications -> /Applications` symlink for
        # drag-install); only Ghostex.app belongs in $out.
        find "$out/Applications" -maxdepth 1 -type l -delete
        # The app bundles a native CLI (which resolves its sibling skills/
        # directory through symlinks); expose it on PATH.
        ln -s $out/Applications/Ghostex.app/Contents/Resources/CLI/ghostex $out/bin/ghostex
        ln -s $out/Applications/Ghostex.app/Contents/Resources/CLI/gx $out/bin/gx

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        mkdir -p $out/opt $out/bin $out/share
        cp -r opt/ghostex $out/opt/ghostex

        # Upstream entry points: both exec gxserver/bin/ghostex (a static
        # binary), which routes to the desktop GUI when a display is
        # available. Wrapped (rather than symlinked) so child processes —
        # the GUI and CEF helpers — inherit the runtime library path.
        makeWrapper $out/opt/ghostex/gxserver/bin/ghostex $out/bin/ghostex \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath linuxLibs}"
        makeWrapper $out/opt/ghostex/gxserver/bin/ghostex $out/bin/gx \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath linuxLibs}"

        # Desktop entry + icon, rewritten from /usr paths to $out.
        mkdir -p $out/share/applications
        substitute usr/share/applications/ghostex.desktop \
          $out/share/applications/ghostex.desktop \
          --replace-fail /usr/bin/ghostex $out/bin/ghostex \
          --replace-fail /usr/bin/gx $out/bin/gx
        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp usr/share/icons/hicolor/256x256/apps/ghostex.png \
          $out/share/icons/hicolor/256x256/apps/

        runHook postInstall
      '';

  meta = {
    description = "AI development workspaces and terminals";
    longDescription = ''
      Ghostex provides native AI development workspaces, terminals, and
      project tools, with an embedded browser and IDE.

      Notes:
      - The Linux GUI requires an X11 display (XWayland on Wayland sessions).
      - Browser surfaces need a Chromium (CEF) runtime that Ghostex downloads
        itself on first launch and reuses across updates.
    '';
    homepage = "https://github.com/maddada/Ghostex";
    license = lib.licenses.mit;
    mainProgram = "ghostex";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ toyvo ];
  };
}
