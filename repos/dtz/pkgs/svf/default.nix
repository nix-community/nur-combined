{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-18";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "e197f2d696e474a9dcf3a8a7d98b6c228c6d1d44";
      sha256 = "0sw4hvl7bm4amhh3my41s25q1c1pc1b3c3zf6nsxhadd6n7jqb6m";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
