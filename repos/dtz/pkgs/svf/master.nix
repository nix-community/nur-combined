{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-12-17";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "a5ab0336dc9eceae782def73adf79dc51d50f97d";
      sha256 = "0v9rxrv2r5f4vmy6v2rmkfv3ai43xjzhdjp4zli8l4yfwpxzla6b";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
