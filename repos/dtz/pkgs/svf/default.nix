{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-11";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "710bd3fe98940d69a9e97ca7864a5b873b64c579";
      sha256 = "0zhrna1w60gc0phmaigp76iz2xnj1ry07azy7qgf5by8i7vvllfi";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
