{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-26";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "bb0c79b595a549c5a30b0df2bb55b7120d6cdc1f";
      sha256 = "0zhda6w9nyrhxcig3nyw12yvqh2j7krl13a7p33161w86xwv09mi";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
