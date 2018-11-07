{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-11-07";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "11efbf1787fa89ebeba6ce2a30770c009b652bb4";
      sha256 = "03ij0x5kx6qjg9y95w6lzqf37vhd5c2gzccabwpzlkkdxfqf69x9";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
