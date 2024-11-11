{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "copacabana";
  version = "0.0~git20241110.f699088";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "copacabana";
    rev = "f699088e193b79c38395a61bec32b3bb53650d8a";
    hash = "sha256-UM4qPGMmtbCi4NEeNYQNaBB/l1UmZTf+KQw7TZlgvz8=";
  };

  installPhase = ''
    mkdir -p $out/copacabana/cmake/asset
    install -D $src/copacabana/cmake/*.cmake $out/copacabana/cmake/
    install -D $src/copacabana/cmake/asset/* $out/copacabana/cmake/asset/
  '';

  meta = with lib; {
    description = "CMake tools for the Kumi and Eve projects";
    homepage = "https://github.com/jfalcou/copacabana";
    license = licenses.boost;
    platforms = platforms.all;
  };
}
