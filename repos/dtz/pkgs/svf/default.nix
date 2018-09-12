{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-09-11";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "ae9f56563d520f3631c16514fff0c7f1853f9d5f";
      sha256 = "1zf87h08qkd7zd4zxjfk8anfa5i3khm159brjy11p051bgwk04pi";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
