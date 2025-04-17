{
  stdenv,
  fetchurl,
  lib,
  makeWrapper,
  autoPatchelfHook,
  # lib
  julia,
  libdbusmenu-gtk3,
  gdk-pixbuf,
  cairo,
  at-spi2-atk,
  harfbuzz,
  glib,
  pango,
  libuuid,
  libgcrypt,
  xz,
  lz4,
  libgpg-error,
  libepoxy,
  fontconfig,
  gtk3,
  nss,
  nspr,
  ...
}:

stdenv.mkDerivation rec {
  pname = "reqable";
  version = "2.30.3";
  src = fetchurl {
    url = "https://pkgs.reqable.com/download/reqable-app-linux-x86_64.deb?platform=linux&arch=x86_64&version=${version}&ext=deb";
    hash = "sha256-j7yER4kYRedHeJ7DiWXjQdoP2s/Wq7TaQ6qwequxFgs=";
  };

  libraries = [
    julia
    libdbusmenu-gtk3
    gdk-pixbuf
    cairo
    at-spi2-atk
    harfbuzz
    glib
    pango
    libuuid
    libgcrypt
    xz
    lz4
    libgpg-error
    libepoxy
    fontconfig
    gtk3
    nss
    nspr
  ];

  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz
  '';

  buildInputs = [
    autoPatchelfHook
    makeWrapper
  ] ++ libraries;

  installPhase = ''

        mv usr $out
        ln -s $out/share/reqable/lib $out

        mkdir -p $out/share/icons/hicolor/scalable/apps
        cp $out/share/pixmaps/reqable.png $out/share/icons/hicolor/scalable/apps/

        makeWrapper $out/share/reqable/reqable $out/bin/reqable \
    --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS" \
          --prefix LD_LIBRARY_PATH : $out/lib:${lib.makeLibraryPath libraries}

        sed -i "s|Exec=.*|Exec=$out/bin/reqable|" $out/share/applications/*.desktop


  '';
}
