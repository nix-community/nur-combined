{ stdenv, lib, fetchurl, bison, flex }:
stdenv.mkDerivation rec {
  name = "fbset-${version}";
  version = "2.1-30";

  src = fetchurl {
    url = "http://ftp.debian.org/debian/pool/main/f/fbset/fbset_2.1.orig.tar.gz";
    sha256 = "0f4kxaxr0i73k74g1qqcgw3hfjgqpsrfpim167wnglxjsxia0zsi";
  };

  patchPhase = ''
    substituteInPlace Makefile --replace "/usr" $out
    sed -i '/mknod/d' Makefile
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  buildInputs = [ bison flex ];

  preInstall = ''
    mkdir -p $out/man
    mkdir -p $out/sbin
  '';

  meta = with lib; {
    description = "Show and modify frame buffer device settings";
    license = licenses.gpl2;
    homepage = http://users.telenet.be/geertu/Linux/fbdev/;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.linux;
  };
}
