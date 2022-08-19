{ stdenv, lib, fetchFromGitHub, gtk3, pkgconfig, gobject-introspection }:

stdenv.mkDerivation rec {
  pname = "gtk3-nocsd";

  version = "3.0";

  src = fetchFromGitHub {
    owner = "PCMan";
    repo = "gtk3-nocsd";
    rev = "v${lib.versions.major version}";
    sha256 = "sha256-i9KvM4HeYRuHoJT4vTSnQfCiIzSCv35eXtvSiAeYa/Q=";
  };

  buildInputs = [
    gtk3 gobject-introspection
  ];
  nativeBuildInputs = [
    pkgconfig
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "A hack to disable gtk+ 3 client side decoration";
    license = licenses.lgpl21;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
