{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-24";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "90c98559a0cfd8df2fb7aafb0a0080ae885ea93e";
      sha256 = "15kddcpzsv3q3fm01zc7mfb5a4qkfkj4dwc871v1jpvjr4m9jaks";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
