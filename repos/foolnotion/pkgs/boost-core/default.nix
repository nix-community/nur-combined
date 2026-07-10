{ lib, stdenv, fetchFromGitHub, boostConfig 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-core";
  version = "1.91.0.beta1";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "core";
    rev = "boost-${version}";
    sha256 = "sha256-Y9xNI7tI6LIW4WuHIKcR7Ippo7IVal4D9vr5q7MiUY8=";
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