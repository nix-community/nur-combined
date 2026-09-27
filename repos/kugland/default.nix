{
  pkgs ? import <nixpkgs> { },
  ...
}:
rec {
  auditok = pkgs.callPackage ./pkgs/auditok { };
  bip39 = pkgs.callPackage ./pkgs/bip39 { };
  bop = pkgs.callPackage ./pkgs/bop { };
  cursor = pkgs.callPackage ./pkgs/cursor { };
  ffsubsync = pkgs.callPackage ./pkgs/ffsubsync { inherit auditok pysubs2; };
  musescore = pkgs.callPackage ./pkgs/musescore { };
  my-bookmarks-pl = pkgs.callPackage ./pkgs/my-bookmarks-pl { };
  neocities-deploy = pkgs.callPackage ./pkgs/neocities-deploy { };
  pd-else = pkgs.callPackage ./pkgs/pd-else { inherit puredata; };
  puredata = pkgs.callPackage ./pkgs/puredata { };
  puredata-with-plugins =
    plugins: pkgs.callPackage ./pkgs/puredata/wrapper.nix { inherit plugins puredata; };
  pysubs2 = pkgs.callPackage ./pkgs/pysubs2 { };
}
