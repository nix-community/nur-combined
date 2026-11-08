{pkgs ? import <nixpkgs> {}}: {
  cheatmd = pkgs.callPackage ./pkgs/cheatmd {};
  operations = pkgs.callPackage ./pkgs/operations {};
  revshell = pkgs.callPackage ./pkgs/revshell {};
  spilltea = pkgs.callPackage ./pkgs/spilltea {};
  steep = pkgs.callPackage ./pkgs/steep {};
}
