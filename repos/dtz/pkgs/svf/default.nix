{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-19";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "8607025bb1ec0f69f6df8f6d163f43bc9cf502ac";
      sha256 = "0s0cp5ykkj6p79xz6xxbkj5sibasjih1kh3xfs671asj18g0rj3k";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
