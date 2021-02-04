{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "imgdecode";
  version = "1.1";

  src = fetchurl {
    url = "mirror://sourceforge/garmin-img/imgdecode-${version}.tar.gz";
    sha256 = "0rxrzvbpw6cbgq0fab7hy8n9jhp98x5y48i69jijxdhfyjivs02m";
  };

  postPatch = ''
    substituteInPlace garminimg.cc \
      --replace "<stdio.h>" "<cstring>"
  '';

  configurePhase = "./configure || true";

  installPhase = "install -Dm755 imgdecode -t $out/bin";

  meta = with lib; {
    description = "IMG Decoder";
    homepage = "https://sourceforge.net/projects/garmin-img/";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
