{ config, lib, pkgs, ... }:

with lib; {
  users.users.root = {
    shell = mkIf config.programs.zsh.enable pkgs.zsh;
  };
  home-manager.users.root = lib.mkMerge (
    [ (import ../vincent/core) ]
  );
}
