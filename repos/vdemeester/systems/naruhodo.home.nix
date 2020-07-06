{ pkgs, lib, ... }:

with lib;
let
  hostname = "hokkaido";
  secretPath = ../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);
in
{
  imports = [
    (import ../users/vincent/core)
    # mails
    (import ../users/vincent/mails { inherit hostname pkgs; })
    # dev
    (import ../users/vincent/dev)
    # containers
    ../users/vincent/containers/kubernetes.nix
    ../users/vincent/containers/openshift.nix
  ];

  home.extraOutputsToInstall = [ "man" ];
  home.file.".local/share/applications/redhat-vpn.desktop".source = ./naruhodo/redhat-vpn.desktop;

  programs.bash.enable = lib.mkForce false;
  programs.man.enable = true;

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      defaultCacheTtlSsh = 7200;
    };
  };
}
