{ config, lib, pkgs, ... }:

let
  inherit (lib) importTOML;
  metadata = importTOML ../../ops/hosts.toml;
in
{
  users.users.houbeb = {
    createHome = true;
    description = "Houbeb Ben Othmene";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = metadata.ssh.keys.houbeb;
  };
  home-manager.users.houbeb = {
    home.packages = with pkgs; [ hello ];
  };
}
