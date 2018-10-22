{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-22";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "bc932653dab0f0a0f746bee366ce071505b83ae8";
      sha256 = "1wviiqwz3ngqfcsiahgl447gb5m2lmzqj1cknmdn5lmgmgkcr5av";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
