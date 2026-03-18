{ lib, stdenv, fetchFromGitHub, boostConfig 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-core";
  version = "1.90.0";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "core";
    rev = "boost-${version}";
    sha256 = "sha256-R38lFVHSoNUYyR3e37PwK/weMI+mbtMmmpX9iPMczs8=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/boost
    cp -r include/boost/* $out/include/boost/
    runHook postInstall
  '';

  propagatedBuildInputs = [ boostConfig ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Boost core utility headers";
    homepage = "https://github.com/boostorg/core";
    license = licenses.boost;
    platforms = platforms.all;
  };
}