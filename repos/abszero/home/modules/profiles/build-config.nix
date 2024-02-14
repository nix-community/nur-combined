# Profile that disables every package
{ lib, ... }:

let inherit (lib) mkForce; in

{
  imports = [ ./base.nix ];

  # programs = builtins.mapAttrs
  #   (_: v: optionalAttrs (v ? package) { package = pkgs.emptyDirectory; })
  #   config.programs;

  home.packages = mkForce [ ];
}
