# User setup
{ config, lib, pkgs, ... }:
let
  secrets = config.my.secrets;
  cfg = config.my.system.users;
  groupExists = grp: builtins.hasAttr grp config.users.groups;
  groupsIfExist = builtins.filter groupExists;
in
{
  options.my.system.users = with lib; {
    enable = my.mkDisableOption "user configuration";
  };

  config = lib.mkIf cfg.enable {
    users = {
      mutableUsers = false; # I want it to be declarative.

      users = {
        root = {
          inherit (secrets.users.root) hashedPassword;
        };

        ${config.my.username} = {
          inherit (secrets.users.${config.my.username}) hashedPassword;
          description = "Bruno BELANYI";
          isNormalUser = true;
          shell = pkgs.zsh;
          extraGroups = groupsIfExist [
            "audio" # sound control
            "media" # access to media files
            "networkmanager" # wireless configuration
            "plugdev" # usage of ZSA keyboard tools
            "video" # screen control
            "wheel" # `sudo` for the user.
          ];
          openssh.authorizedKeys.keys = with builtins;
            let
              keyDir = ./ssh;
              contents = readDir keyDir;
              names = attrNames contents;
              files = filter (name: contents.${name} == "regular") names;
              keys = map (basename: readFile (keyDir + "/${basename}")) files;
            in
            keys;
        };
      };
    };
  };
}
