{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-21";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "21c4b6a1d82fbad32b6b3d2701365774c70cb4d1";
      sha256 = "1kyn3sxnx5sd0bx71gzrccrvxscw5a25mnvh5kfdpyj7yy3jzndw";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
