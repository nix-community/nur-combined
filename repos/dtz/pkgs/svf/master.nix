{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-11-04";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "546a6166a831cea5bfa1e16b422e5cc73e1ed8df";
      sha256 = "16vc4imyi867fbm4h4lf9b2kxh6l1bmlyrjss6rflv5rlxaxk6yw";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
