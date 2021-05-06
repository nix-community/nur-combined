# User setup
{ config, lib, pkgs, ... }:
let
  my = config.my;
  groupIfExists = grp:
    lib.lists.optional
      (builtins.hasAttr grp config.users.groups)
      grp;
  groupsIfExist = builtins.concatMap groupIfExists;
in
{
  users.mutableUsers = false; # I want it to be declarative.

  # Define user accounts and passwords.
  users.users.root.hashedPassword = my.secrets.users.root.hashedPassword;
  users.users.ambroisie = {
    hashedPassword = my.secrets.users.ambroisie.hashedPassword;
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
}
