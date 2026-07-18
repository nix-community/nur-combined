{
  lib,
  stdenv,
  pake,
  dpkg,
  autoPatchelfHook,
  makeBinaryWrapper,
  nodejs_22,
  pnpm,
  cargo,
  rustc,
  curl,
  wget,
  pkg-config,
  file,
  gnutar,
  rustPlatform,
  imagemagick,
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk3,
  gtk4,
  harfbuzz,
  fontconfig,
  freetype,
  libdrm,
  libepoxy,
  libglvnd,
  libpng,
  libsoup_3,
  libxkbcommon,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxcursor,
  libxi,
  libxinerama,
  libxrender,
  libayatana-appindicator,
  libdbusmenu,
  libayatana-indicator,
  ayatana-ido,
  mesa,
  pango,
  wayland,
  webkitgtk_4_1,
}:

{
  pname,
  appName ? pname,
  url,
  icon,
  version ? pake.version,
  meta ? { },
}:

let
  executableName = "pake-${pname}";
in
assert lib.assertMsg (pname == lib.toLower pname) "makePakeApp: pname must be lowercase";
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeBinaryWrapper
    pake
    nodejs_22
    pnpm
    cargo
    rustc
    curl
    wget
    pkg-config
    file
    gnutar
    imagemagick
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    gdk-pixbuf
    glib
    glib-networking
    gtk3
    gtk4
    harfbuzz
    fontconfig
    freetype
    libdrm
    libepoxy
    libglvnd
    libpng
    libsoup_3
    libxkbcommon
    libayatana-appindicator
    libdbusmenu
    libayatana-indicator
    ayatana-ido
    mesa
    pango
    wayland
    webkitgtk_4_1
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxcursor
    libxi
    libxrender
    libxinerama
  ];

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/cache"
    export XDG_CONFIG_HOME="$TMPDIR/config"
    export PAKE_RUNTIME_DIR="$TMPDIR/pake-runtime"
    export CI="true"
    export CARGO_HOME="$TMPDIR/cargo-home"
    export CARGO_NET_OFFLINE="true"

    vendor_dir="$TMPDIR/cargo-vendor"
    cp -Lr --reflink=auto "${pake.cargoDeps}" "$vendor_dir"
    chmod -R u+w "$vendor_dir"

    mkdir -p "$PAKE_RUNTIME_DIR/.cargo"
    sed "s|@vendor@|$vendor_dir|g" "${pake.cargoDeps}/.cargo/config.toml" > "$PAKE_RUNTIME_DIR/.cargo/config.toml"

    icon_rgba="$TMPDIR/pake-icon.png"
    magick "${icon}" -alpha on -background none -define png:color-type=6 "$icon_rgba"

    mkdir -p build
    cd build
    pake "${url}" --name "${appName}" --icon "$icon_rgba" --targets deb

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    deb="$(ls -1 build/*.deb | head -n 1)"
    if [ -z "$deb" ]; then
      echo "No .deb produced by pake" >&2
      exit 1
    fi

    dpkg-deb -x "$deb" app

    mkdir -p "$out"
    shopt -s nullglob
    for dir in app/usr app/opt; do
      if [ -e "$dir" ]; then
        cp -a "$dir" "$out/"
      fi
    done

    mkdir -p "$out/bin"
    # __NV_DISABLE_EXPLICIT_SYNC -> https://github.com/tauri-apps/tauri/issues/10702
    wrapProgram "$out/usr/bin/${executableName}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}" \
      --set __NV_DISABLE_EXPLICIT_SYNC 1
    ln -s "$out/usr/bin/${executableName}" "$out/bin/${pname}"

    runHook postInstall
  '';

  meta = meta // {
    mainProgram = meta.mainProgram or pname;
    platforms = meta.platforms or lib.platforms.linux;
  };
})
