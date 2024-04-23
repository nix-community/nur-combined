{ stdenv, lib }:

stdenv.mkDerivation rec {
  name = "nx-utils-${version}";
  version = "1.0";
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 nxc-autobk.sh $out/bin/nxc-autobk
    install -Dm755 nxc-bkdiff.sh $out/bin/nxc-bkdiff
  '';
  meta = with lib; {
    description = "Additional utilities for working with a NixOS system.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}