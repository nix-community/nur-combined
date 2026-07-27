{ config, lib, pkgs, ... }:

let
  inherit (lib) lists attrsets mkIf optionals versionOlder importTOML;
  metadata = importTOML ../../ops/hosts.toml;
in
{
  users.users.root = {
    shell = mkIf config.programs.zsh.enable pkgs.zsh;
    openssh.authorizedKeys.keys = metadata.ssh.keys.root;
  };
  home-manager.users.root = lib.mkMerge (
    [
      (import ../vincent/core/zsh.nix)
      (import ../vincent/core/ssh.nix)
    ]
    ++ optionals (versionOlder config.system.nixos.release "21.11") [{
      # manpages are broken on 21.05 and home-manager (for some reason..)
      manual.manpages.enable = false;
    }] ++ [{
      home.stateVersion = "22.05";
    }]
  );
}
