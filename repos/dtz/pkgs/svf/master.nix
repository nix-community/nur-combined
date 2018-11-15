{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-11-13";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "b9c521b77ebf8cafcd8c2533f977eafe1dc44a4b";
      sha256 = "0za4k4vj5kk3kqvnkslwwg1c8s5mqwxnrzjhqsj4vbhff9zq2r3i";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
