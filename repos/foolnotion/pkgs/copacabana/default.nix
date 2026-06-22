{ lib, stdenv, fetchFromGitHub 
, nix-update-script
}:
stdenv.mkDerivation rec {
  name = "copacabana";
  version = "0.0~git20260406.da2a51f";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "copacabana";
    rev = "da2a51f4ab30e76c2cc7d8601e85f7eaed8832b4";
    hash = "sha256-EuMBkFOIFEJUwRVWnopIe95wCmHO3i3Qy8gMd1r8bWY=";
  };

  installPhase = ''
    mkdir -p $out/copacabana/cmake/asset
    install -D $src/copacabana/cmake/*.cmake $out/copacabana/cmake/
    install -D $src/copacabana/cmake/asset/* $out/copacabana/cmake/asset/
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "CMake tools for the Kumi and Eve projects";
    homepage = "https://github.com/jfalcou/copacabana";
    license = licenses.boost;
    platforms = platforms.all;
  };
}
