{
  lib,
  stdenv,
  pake,
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
  
  dpkg ? null,
  autoPatchelfHook ? null,
  alsa-lib ? null,
  atk ? null,
  at-spi2-atk ? null,
  at-spi2-core ? null,
  cairo ? null,
  cups ? null,
  dbus ? null,
  gdk-pixbuf ? null,
  glib ? null,
  glib-networking ? null,
  gtk3 ? null,
  gtk4 ? null,
  harfbuzz ? null,
  fontconfig ? null,
  freetype ? null,
  libdrm ? null,
  libepoxy ? null,
  libglvnd ? null,
  libpng ? null,
  libsoup_3 ? null,
  libxkbcommon ? null,
  libx11 ? null,
  libxcomposite ? null,
  libxdamage ? null,
  libxext ? null,
  libxfixes ? null,
  libxrandr ? null,
  libxcb ? null,
  libxcursor ? null,
  libxi ? null,
  libxinerama ? null,
  libxrender ? null,
  libayatana-appindicator ? null,
  libdbusmenu ? null,
  libayatana-indicator ? null,
  ayatana-ido ? null,
  mesa ? null,
  pango ? null,
  wayland ? null,
  webkitgtk_4_1 ? null,

  apple-sdk_14 ? null,
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
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib atk at-spi2-atk at-spi2-core cairo cups dbus gdk-pixbuf glib glib-networking
    gtk3 gtk4 harfbuzz fontconfig freetype libdrm libepoxy libglvnd libpng libsoup_3
    libxkbcommon libx11 libxcomposite libxdamage libxext libxfixes libxrandr libxcb
    libxcursor libxi libxinerama libxrender libayatana-appindicator libdbusmenu
    libayatana-indicator ayatana-ido mesa pango wayland webkitgtk_4_1
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_14
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
    pake "${url}" --name "${appName}" --icon "$icon_rgba" --targets ${if stdenv.hostPlatform.isLinux then "deb" else "app"}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${if stdenv.hostPlatform.isLinux then ''
      deb="$(ls -1 *.deb | head -n 1)"
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
    '' else ''
      echo "Checking for .app files:"
      find . -maxdepth 1 -name "*.app"
      app_path=(*.app)
      if [ ''${#app_path[@]} -eq 0 ] || [ ! -e "''${app_path[0]}" ]; then
        echo "No .app produced by pake" >&2
        exit 1
      fi

      mkdir -p "$out/Applications"
      cp -a "''${app_path[0]}" "$out/Applications/"
      
      out_app=("$out/Applications/"*.app)
      mkdir -p "$out/bin"
      ln -s "''${out_app[0]}/Contents/MacOS/${executableName}" "$out/bin/${pname}"
    ''}

    runHook postInstall
  '';

  meta = meta // {
    mainProgram = meta.mainProgram or pname;
    platforms = meta.platforms or lib.platforms.all;
  };
})
