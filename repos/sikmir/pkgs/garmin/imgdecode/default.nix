{ lib, stdenv, fetchurl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "imgdecode";
  version = "1.1";

  src = fetchurl {
    url = "mirror://sourceforge/garmin-img/imgdecode-${finalAttrs.version}.tar.gz";
    hash = "sha256-VQC9o/QOti6jTCYi4ktH6UKZLPLwLOUAfosZftf+uWc=";
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
})
