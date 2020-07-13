# To build the installer for your system's architecture:
#
#   nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
#
# To build a 32-bit installer, overrride the value of the `system` parameter:
#
#   nix-build <SAME AS BEFORE> --argStr system i686-linux
#

{ config, lib, pkgs, system ? builtins.currentSystem, ... }:

with lib;
let
  secretPath = ../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);

  isAuthorized = p: builtins.isAttrs p && p.authorized or false;
  authorizedKeys = lists.optionals secretCondition (
    attrsets.mapAttrsToList
      (name: value: value.key)
      (attrsets.filterAttrs (name: value: isAuthorized value) (import secretPath).ssh)
  );
in
{
  imports = [
    # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = authorizedKeys;
  };

  environment.etc = {
    "install.sh" = {
      source = ./install.sh;
      mode = "0700";
    };

    "configuration.nix" = {
      source = ./installer_configuration.nix;
      mode = "0600";
    };
  };
}
