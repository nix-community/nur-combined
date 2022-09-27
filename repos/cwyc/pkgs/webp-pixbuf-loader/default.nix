{
  lib, stdenv, fetchFromGitHub,
  meson, cmake, ninja, pkg-config,
  gdk-pixbuf, libwebp
}:
let
  moduleDir = gdk-pixbuf.moduleDir;
in stdenv.mkDerivation {
  pname = "webp-pixbuf-loader";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "aruiz";
    repo = "webp-pixbuf-loader";
    rev = "ffddc060497ee11d6cc573dae01a528b357b91ec";
    sha256 = "1dp4xrdz2p4vx2gd871vcy0nk6lkai4r3ddiw38ic6a8pq9npn11";
  };

  nativeBuildInputs = [meson cmake ninja pkg-config];
  buildInputs = [gdk-pixbuf libwebp];

  mesonFlags = [
    "-Dgdk_pixbuf_query_loaders_path=${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders"
    "-Dgdk_pixbuf_moduledir=${placeholder "out"}/${moduleDir}"
  ];

  preInstallPhases = ["preInstallPhase"];
  preInstallPhase = ''
    #environment variables controlling gdk-pixbuf-query-loaders
    export GDK_PIXBUF_MODULE_FILE=$out/${moduleDir}/../loaders.cache
    export GDK_PIXBUF_MODULEDIR=$out/${moduleDir}
  '';

  meta = with lib; {
    description = "WebP GDK Pixbuf Loader library";
    homepage = "https://github.com/aruiz/webp-pixbuf-loader";
    licence = licenses.lgpl2Plus;
    platforms = platforms.unix;
    maintainers = [maintainers.cwyc];
  };
}
