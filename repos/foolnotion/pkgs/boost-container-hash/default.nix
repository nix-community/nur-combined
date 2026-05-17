{ lib, stdenv, fetchFromGitHub, boostConfig 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-container-hash";
  version = "1.91.0";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "container_hash";
    rev = "boost-${version}";
    sha256 = "sha256-gMwrjLDmrB7eOYkvwiE4zV2DHI67pqctPKGJttphcSg=";
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
    description = "Boost container hash support headers";
    homepage = "https://github.com/boostorg/container_hash";
    license = licenses.boost;
    platforms = platforms.all;
  };
}