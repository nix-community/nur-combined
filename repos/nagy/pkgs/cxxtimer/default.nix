{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "cxxtimer";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "andremaravilha";
    repo = "cxxtimer";
    rev = "v${version}";
    sha256 = "1sxjkpvbkpydcmnkqh7k1wg26vf9ncih90qfrr7hibsnwqavar4j";
  };

  buildInputs = [ ];

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm644 $src/cxxtimer.hpp $out/include/cxxtimer.hpp
  '';

  meta = with lib; {
    description = "A timer for modern C++";
    homepage = "https://github.com/andremaravilha/cxxtimer";

    license = licenses.mit;
    platforms = platforms.all;
  };
}
