{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-04";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "4ed1c049dee6e86ac898e5916708b6d1b5ddc416";
      sha256 = "1x9s1k6hjxqf2av3bgc6k5vx7b7q0rrmv77a45vqlz8zb6z2lm5x";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
