{ stdenv, fetchurl }:
let
  version = "1.1";
in
stdenv.mkDerivation {
  pname = "imgdecode";
  inherit version;

  src = fetchurl {
    url = "mirror://sourceforge/garmin-img/imgdecode-${version}.tar.gz";
    sha256 = "0rxrzvbpw6cbgq0fab7hy8n9jhp98x5y48i69jijxdhfyjivs02m";
  };

  postPatch = ''
    substituteInPlace garminimg.cc \
      --replace "<stdio.h>" "<cstring>"
  '';

  configurePhase = "./configure || true";

  installPhase = ''
    install -Dm755 imgdecode -t $out/bin
  '';

  meta = with stdenv.lib; {
    description = "IMG Decoder";
    homepage = "https://sourceforge.net/projects/garmin-img/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
