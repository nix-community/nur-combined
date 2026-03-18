{ lib, stdenv, fetchFromGitHub 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-config";
  version = "1.90.0";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "config";
    rev = "boost-${version}";
    sha256 = "sha256-t1JEqiyD0xtB+3st9plPAVZvCtsQCoFCAFh9nEHUK9g=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/boost
    cp -r include/boost/* $out/include/boost/
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Boost configuration headers";
    homepage = "https://github.com/boostorg/config";
    license = licenses.boost;
    platforms = platforms.all;
  };
}