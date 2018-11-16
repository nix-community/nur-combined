{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-11-15";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "1bc5bc461d15502f3eee6ecbb6d1b2dd4fbb18bf";
      sha256 = "14n2fg0an2naahwcvsjaxvrdjm94n2viy259sqnhh9qxvzwjwds6";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
