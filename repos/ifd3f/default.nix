{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hello = pkgs.hello.overrideAttrs (old: {
    meta = old.meta // {
      description = "the hello from nixpkgs, reproduced here to act as a smoke test";
    };
  });

  argen = pkgs.callPackage ./pkgs/argen { };
}
