{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-09-25";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "5b27b0f9f3f25804c924c8304f0680228ef5276b";
      sha256 = "1cw26drp8wv0ijm96cd38p2mlwkkr16k7x4c0inc5lk0zbx6gjmj";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
