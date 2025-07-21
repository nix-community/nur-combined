{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlays` names are special
  # lib = import ./lib {inherit pkgs;}; # functions
  # modules = import ./modules; # NixOS modules
  # overlays = import ./overlays; # nixpkgs overlays

  ark = pkgs.callPackage ./nix-config/packages/ark {};
  tackler = pkgs.callPackage ./nix-config/packages/tackler {};
}
