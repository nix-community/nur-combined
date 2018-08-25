{ pkgs ? import <nixpkgs> {} }: {
  asql = pkgs.callPackage ./asql.nix {};
  x11 = pkgs.recurseIntoAttrs (pkgs.callPackages ./x11 {});
}
