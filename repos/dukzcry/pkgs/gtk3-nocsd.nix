{ stdenv, lib, fetchFromGitHub, gtk3, pkg-config, gobject-introspection }:

stdenv.mkDerivation rec {
  pname = "gtk3-nocsd";
  version = "2022-10-15";

  src = fetchFromGitHub {
    owner = "fredldotme";
    repo = "gtk3-nocsd";
    rev = "a356bf79d1c8cabbb0f1972f4f0023ae01bd16bc";
    sha256 = "sha256-zqvCpVlf763gYP6brkwoqMe9t9cHr73XM7Pcyh6FoOw=";
  };

  buildInputs = [
    gtk3 gobject-introspection
  ];
  nativeBuildInputs = [
    pkg-config
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
