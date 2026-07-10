{ lib, stdenv, fetchFromGitHub 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-config";
  version = "1.91.0.beta1";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "config";
    rev = "boost-${version}";
    sha256 = "sha256-40a2Ho63M5yWGQ6FDFeZxs9yJy1A8Ec6KcW4FvT2TaQ=";
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