{ config, pkgs, lib, materusFlake, ... }:
{
  imports = [
    ./nixpkgs.nix
    ./packages
  ];
  config._module.args.materusPkgs = (import materusFlake { inherit pkgs; }) //
  (if pkgs.system == "x86_64-linux" then { i686Linux = import materusFlake { pkgs = pkgs.pkgsi686Linux; }; } else { });
  #config.nixpkgs.config.allowUnfree = builtins.trace config.nixpkgs.config.allowUnfree true;
}
