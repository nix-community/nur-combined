{
  stdenv,
  fetchgit,
  lib,
}:
stdenv.mkDerivation {
  name = "hardlink-osx";
  version = "master";
  pname = "hln";
  src = fetchgit {
    url = "https://github.com/selkhateeb/hardlink.git";
    hash = "sha256-vr5NTTdMwCVoBD+ffbXB1M4Vt5c30zWJC2Mn+Cssb5E=";
  };

  buildInputs = [
  ];

  buildPhase = ''
    				${stdenv.cc}/bin/cc hln.c -o hln
                	runHook preBuild
            		runHook postBuild

  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r hln $out/bin

    runHook postInstall
  '';

}
