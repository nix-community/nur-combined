{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "cmake-utils";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "karnkaul";
    repo = "cmake-utils";
    rev = "v${version}";
    hash = "sha256-rpU2iJ6tQ3j3FLccUGTqKKpZZHQIZ8BI3iawMMsk6GY=";
  };

  installPhase = ''
    mkdir $out
    install -D $src/*.cmake $out/
  '';

  meta = with lib; {
    description = "Utility functions for CMake projects";
    homepage = "https://github.com/karnkaul/cmake-utils";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
