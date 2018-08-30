{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-08-28";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "a229e4c934a6c2814ed907aeb453b716de75bc04";
      sha256 = "14fyaa8k6jbpp5gv9lxs3b4rnpzzf4055r6467npd86xgbqppr8x";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
