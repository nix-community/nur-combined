{ stdenv
, lib
# , fetchurl
, fetchzip
, dpkg
, python3
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "steamlink";

  # version = "1.0.7";
  # src = fetchurl {
  #   url = "https://archive.raspberrypi.org/debian/pool/main/s/${pname}/${pname}_${version}_armhf.deb";
  #   sha256 = "176k9qpqwhr3137l7scjzji836xnzy5v0qmvsli0n7i7jma723vw";
  # };
  # unpackPhase = "dpkg-deb -x $src .";
  # src = fetchzip {
  #   url = "https://archive.raspberrypi.org/debian/pool/main/s/${pname}/${pname}_${version}.tar.xz";
  #   sha256 = "13n334gwjgw1aqzsw42w00cn04xbfac15cjg6nxdcg3268znfcgj";
  # };

  version = "1.1.65.164";
  src = fetchzip {
    url = "http://media.steampowered.com/steamlink/rpi/${pname}-rpi3-${version}.tar.gz";
    sha256 = "0v621g50np6jilbwnd57qqksr8i0pfcag72v9j4hlj0i9ac5zhka";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ python3 ];

  installCheckPhase = ''
    $out/bin/steamlink --help
  '';

  # preBuild = "ls";

  meta = with lib; {
    description = "Lightweight remote Steam streaming package for Raspberry Pi.";
    license = licenses.unfree;
    homepage = "TODO";
    maintainers = [ maintainers.drewrisinger ];
    platforms = [ "aarch64-linux" "armv7l-linux" "armv6l-linux" ];
  };
}
