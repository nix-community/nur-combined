{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-11-12";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "415c3e82e799e0e3e312c61f34f5feb4bbaa8eae";
      sha256 = "1q36jhjmrq7la4bjpa19fi3x3n6k2ddn4y22af1icwlxrbjysy8f";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
