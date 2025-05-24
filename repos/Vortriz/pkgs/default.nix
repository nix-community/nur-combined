{pkgs, ...}: let
  callPackage' = pkg:
    pkgs.callPackage pkg {
      sources = pkgs.callPackages ./sources/generated.nix {};
    };
in {
  niriswitcher = callPackage' ./niriswitcher;
}
