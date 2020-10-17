{ stdenv, fetchurl }:

{ pkg, version, sha256, meta ? { } }:

with stdenv.lib;

stdenv.mkDerivation ({
  name = "hex-source-${pkg}-${version}";

  src = fetchurl {
    url = "https://repo.hex.pm/tarballs/${pkg}-${version}.tar";
    inherit sha256;
  };

  phases = [ "unpackPhase" "installPhase" ];

  unpackCmd = ''
    tar -xf $curSrc contents.tar.gz metadata.config
    mkdir contents
    tar -C contents -xzf contents.tar.gz
    mv metadata.config contents/hex_metadata.config
  '';

  installPhase = ''
    runHook preInstall
    mkdir "$out"
    cp -Hrt "$out" .
    success=1
    runHook postInstall
  '';

  inherit meta;
})
