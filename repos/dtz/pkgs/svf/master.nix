{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2019-01-24";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "14d7435d49f5f857a0c6b15dc870765b5c50ccc7";
      sha256 = "1s1hw8yngd6anq8vavrmbz4s5fn6vs5ynwc9wxwj8csclb8ra1f0";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
