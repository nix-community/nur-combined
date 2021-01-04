{ stdenv
, fetchFromGitHub
, makeWrapper

, curl
, gnumake
, gnutls
, gtk3
, gtkmm3
, pkg-config
, yajl
}:

stdenv.mkDerivation rec {
  pname = "SamRewritten";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "PaulCombal";
    repo = pname;
    rev = "202008";
    sha256 = "ab7903b997675b0d4d7eede15430fc5ca2736e6c25c7f95a7c97e1ce25582a1c";
  };

  nativeBuildInputs = [ gnumake pkg-config ];
  buildInputs = [
    curl
    gnutls
    gtk3
    gtkmm3
    yajl
  ];

  NIX_CFLAGS_LINK = "-pthread";

  makeFlags = [ "PREFIX=$(out)" ];

  postFixup = ''
    substituteInPlace $out/share/applications/samrewritten.desktop \
      --replace /usr/bin/samrewritten $out/bin/samrewritten
  '';

  meta = with stdenv.lib; {
    description = "Steam Achievement Manager For Linux";
    homepage = "https://github.com/PaulCombal/SamRewritten";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
