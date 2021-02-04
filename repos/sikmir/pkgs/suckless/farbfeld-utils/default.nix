{ lib, stdenv, fetchfossil }:

stdenv.mkDerivation {
  pname = "farbfeld-utils";
  version = "2020-11-02";

  src = fetchfossil {
    url = "http://zzo38computer.org/fossil/farbfeld.ui";
    rev = "a195827da5";
    sha256 = "1z24qv09r426v05bljy185sh420kwfa9x1pwz34s63n1hp1v3y20";
  };

  buildPhase = "$CC -o gif2ff gifff.c";

  installPhase = "install -Dm755 gif2ff -t $out/bin";

  meta = with lib; {
    description = "Collection of utilities for farbfeld picture format";
    homepage = "http://zzo38computer.org/fossil/farbfeld.ui/home";
    license = licenses.publicDomain;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
