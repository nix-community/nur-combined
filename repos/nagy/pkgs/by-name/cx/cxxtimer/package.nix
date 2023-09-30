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

  installPhase = ''
    runHook preInstall
    install -Dm444 -t $out/include/ $src/cxxtimer.hpp
    runHook postInstall
  '';

  meta = with lib; {
    description = "A timer for modern C++";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
