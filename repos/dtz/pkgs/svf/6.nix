{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = rec {
    version = "1.5"; # tagged as last LLVM 6 version before moving to LLVM 7
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "SVF-${version}";
      sha256 = "0s0cp5ykkj6p79xz6xxbkj5sibasjih1kh3xfs671asj18g0rj3k";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
