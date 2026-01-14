{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  pake,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  nodejs_22,
  pnpm,
  cargo,
  rustc,
  curl,
  wget,
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
  libayatana-appindicator,
  libdbusmenu,
  libayatana-indicator,
  ayatana-ido,
  mesa,
  pango,
  wayland,
  webkitgtk_4_1,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: let
  pakeSrc = fetchFromGitHub {
    owner = "tw93";
    repo = "Pake";
    rev = "838cc932ffd1db6bc5ca81ced64f73bcd8568175";
    hash = "sha256-sEjj0a9aGCwv5EFn7PWkYU1j3U5MLO7lj0qL2CkfKOM=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    pname = "pake";
    version = pake.version;
    src = pakeSrc;
    cargoRoot = "src-tauri";
    hash = "sha256-OJi0iiXTWZoPzS3HWVXJ2NTlA+xT3je4AC1APEoczbo=";
  };
in {
  pname = "chatgpt";
  version = pake.version;

  dontUnpack = true;

  icon = fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/OpenAI_logo_2025_%28symbol%29.svg/1280px-OpenAI_logo_2025_%28symbol%29.svg.png";
    hash = "sha256-PO3Bl6IS3vq4aP+wsy9sA86a41lyss5yHl9b0FzwXyQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    pake
    nodejs_22
    pnpm
    cargo
    rustc
    curl
    wget
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
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libXcursor
    xorg.libXi
    xorg.libXrender
    xorg.libXinerama
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
    cp -Lr --reflink=auto "${cargoDeps}" "$vendor_dir"
    chmod -R u+w "$vendor_dir"

    icon_rgba="$TMPDIR/chatgpt-icon.png"
    magick "${finalAttrs.icon}" -alpha on -background none -define png:color-type=6 "$icon_rgba"

    mkdir -p "$PAKE_RUNTIME_DIR/.cargo"
    cat > "$PAKE_RUNTIME_DIR/.cargo/config.toml" <<EOF
    [source.crates-io]
    replace-with = "vendored-sources"

    [source.vendored-sources]
    directory = "$vendor_dir"
    EOF

    mkdir -p build
    cd build
    pake https://chatgpt.com/ --name ChatGPT --icon "$icon_rgba"

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
    ln -s "$out/usr/bin/pake-chatgpt" "$out/bin/chatgpt"
    ln -s "$out/usr/bin/pake-chatgpt" "$out/bin/ChatGPT"

    runHook postInstall
  '';

  meta = {
    description = "Desktop application for ChatGPT (packaged via Pake)";
    homepage = "https://chatgpt.com/";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = lib.platforms.linux;
  };
})
