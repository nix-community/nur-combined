{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "imgdecode";
  version = "1.1";

  src = fetchurl {
    url = "mirror://sourceforge/garmin-img/${pname}-${version}.tar.gz";
    sha256 = "sha256-VQC9o/QOti6jTCYi4ktH6UKZLPLwLOUAfosZftf+uWc=";
  };

  postPatch = ''
    substituteInPlace garminimg.cc \
      --replace "<stdio.h>" "<cstring>"
  '';

  configurePhase = "./configure || true";

  installPhase = ''
    install -Dm755 imgdecode -t "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = "IMG Decoder";
    homepage = "https://sourceforge.net/projects/garmin-img/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
