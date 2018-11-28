{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-11-20";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "714832d1e60d0a1d658c49748e24bff5716b02b7";
      sha256 = "0dfxn025inq1bb9pbdpw7dhycb92flqk0xdk8fxrj8cjpj16bgkv";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
