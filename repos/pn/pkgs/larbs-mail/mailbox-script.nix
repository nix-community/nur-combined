{ stdenv, callPackage, fetchgit }:
stdenv.mkDerivation {
  name = "mailbox";

  src = callPackage ../voidrice.nix { };

  installPhase = ''
    mkdir -p $out/bin
    cp .local/bin/statusbar/sb-mailbox $out/bin/sb-mailbox
  '';
}
