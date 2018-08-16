{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-08-15";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "36c9311ca744d89528c6e0190f26cf43036c6190";
      sha256 = "18wd9094h4ywa7lnq2wc15biayqpqbskijf6r4k8z6sckmvaq5zj";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
