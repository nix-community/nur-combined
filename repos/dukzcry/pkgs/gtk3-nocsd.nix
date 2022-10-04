{ stdenv, lib, fetchFromGitHub, gtk3, pkg-config, gobject-introspection }:

stdenv.mkDerivation rec {
  pname = "gtk3-nocsd";
  version = "2016-07-17";

  src = fetchFromGitHub {
    owner = "PCMan";
    repo = "gtk3-nocsd";
    rev = "82ff5a0da54aa6da27232b55eb93e5f4b5de22f2";
    sha256 = "sha256-RxZgSdaRsknyjYrhK3WZCpoqYuGb4RjqA32N4rglN5g=";
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
