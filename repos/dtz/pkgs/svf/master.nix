{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-10-23";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "b2d12e41792a0778eea7c406843adc2a15c03e22";
      sha256 = "1am0mydsi3j3c9wmmgxha941c2j50xb2zhxy63fhrfcdzklfsbpy";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
