{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-08-21";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "806afeacf1a662e503b0191e9065b1549e98f215";
      sha256 = "1s9v8j6gncrk40na9ba8wkyp943cm61cfk4zsgs3ksxsi3dq0b3n";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
