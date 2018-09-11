{ stdenv, fetchFromGitHub, llvm, cmake }:

let
  srcinfo = {
    version = "2018-09-11";
    src = fetchFromGitHub {
      owner = "SVF-tools";
      repo = "SVF";
      rev = "8ee57ed1af6ea9feb9837576013a855f86aa6e51";
      sha256 = "1cc60r0w5x31kf94qcjhli2z4sp2mvhcz2g7cw4vwafsmnaxskyv";
    };
  };
in import ./generic.nix { inherit stdenv llvm cmake srcinfo; } {
  postInstall = ''
    install -Dm755 {.,$out}/bin/saber
    install -Dm755 {.,$out}/bin/wpa
  '';
}
