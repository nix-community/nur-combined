{ lib, stdenv, fetchFromGitHub, boostConfig, boostCore 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-assert";
  version = "1.90.0";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "assert";
    rev = "boost-${version}";
    sha256 = "sha256-uTS34jOzHoo4yz1ZcN6gHYYzR7ihcPlvVrmOHnRK8BU=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/boost
    cp -r include/boost/* $out/include/boost/
    runHook postInstall
  '';

  propagatedBuildInputs = [ boostConfig boostCore ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Boost assertion support headers";
    homepage = "https://github.com/boostorg/assert";
    license = licenses.boost;
    platforms = platforms.all;
  };
}