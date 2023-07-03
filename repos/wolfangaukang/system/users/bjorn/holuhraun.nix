{ config, pkgs, lib, ... }:

let
  gaming_config = config.profile.specialisations.gaming.enable;
  inherit (pkgs) heroic;
  inherit (lib) mkForce;

in {
  imports = [
    ./common.nix
    ./sops.nix
  ];

  users.users.bjorn.passwordFile = config.sops.secrets."user_pwd/bjorn".path;
}
