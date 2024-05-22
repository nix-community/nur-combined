{ pkgs, ... }:

let
  inherit (builtins) readFile;

  identity = import ../resources/identity.nix;
  nur = import ../../nur.nix { inherit pkgs; };
in
{
  imports = [ nur.modules.nixpkgs-issue-163080 ];

  config = {
    users.mutableUsers = false;

    users.groups.${identity.username}.gid = 1000;
    users.users.${identity.username} = {
      isNormalUser = true;
      uid = 1000;
      group = identity.username;
      extraGroups = [ "wheel" ];
      description = identity.name.short;
      hashedPassword = readFile ../local/resources/${identity.username}.passwd;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ identity.ssh ];
    };
  };
}
