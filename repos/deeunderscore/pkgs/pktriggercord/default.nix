{ stdenv, lib
, fetchFromGitHub
, pkg-config
, gtk2
}:
stdenv.mkDerivation rec {
  pname = "pktriggercord";
  version = "0.85.00";

  src = fetchFromGitHub {
    owner = "asalamon74";
    repo = "pktriggercord";
    rev = "v${version}";
    sha256 = "sha256-j81vzIxkOVE3VW6yQ8hgckORPrx4YERJVvqugNDgOZw=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace '$(DESTDIR)/etc/udev/' '$(PREFIX)/etc/udev/'
    substituteInPlace pentax.rules \
      --replace 'GROUP="users"' 'GROUP="camera"'
    substituteInPlace samsung.rules \
      --replace 'GROUP="users"' 'GROUP="camera"'
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk2
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    description = "Remote control software for Pentax cameras";
    homepage = "http://pktriggercord.melda.info/";
    license = licenses.lgpl3Plus;
  };
}