{
  config,
  lib,
  pkgs,
  ...
}:
let
  rootHomeDirectory = if pkgs.stdenv.isDarwin then "/var/root" else "/root";
in
{
  options.userPresets.root.enable = lib.mkEnableOption "root user";

  config = lib.mkIf config.userPresets.root.enable {
    users.users.root = lib.mkMerge [
      {
        name = "root";
        home = rootHomeDirectory;
        shell = pkgs.zsh;
      }
      (lib.mkIf pkgs.stdenv.isLinux {
        hashedPassword = "";
      })
    ];
    nix.settings.trusted-users = [ "root" ];
    home-manager.users.root = {
      home.username = "root";
      home.homeDirectory = rootHomeDirectory;
      profiles.defaults.enable = true;
      programs.zsh.enableCompletion = false;
    };
  };
}
