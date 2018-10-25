{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-25";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "bc54f606835ff8e609e032ee4ea495f8fef8e787";
      sha256 = "1mgahlhqp62rn2knh0s92mbli23pxdqrz8bpgy193fi1acwxqbcz";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
