{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./agents.nix
    ./cli.nix
    ./dev
    ./emacs
    ./firefox.nix
    ./ghostty.nix
    ./git.nix
    ./gnome.nix
    ./gnome.nix
    ./gpg.nix
    ./jujutsu.nix
    ./mozc.nix
    ./pass.nix
    ./virt-manager.nix
  ];

  options.eownerdead = {
    imperm = {
      enable = lib.mkEnableOption "Enable Impermanence";
      path = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/persist";
      };
      dataHome = lib.mkOption {
        type = lib.types.str;
        default = "${config.eownerdead.imperm.path}/.local/share";
      };
    };
  };

  config = {
    eownerdead = {
      cli.enable = true;
      dev.cpp.enable = true;
      dev.nix.enable = true;
      dev.py.enable = true;
      git.enable = true;
      jujutsu.enable = true;
      pass.enable = true;
    };
    home.persistence."/nix/persist" = {
      directories = [
        ".ssh"
      ];
    };
    xdg.userDirs = lib.mkIf config.eownerdead.imperm.enable {
      enable = true;
      createDirectories = true;
      desktop = "${config.eownerdead.imperm.path}/desktop";
      documents = "${config.eownerdead.imperm.path}/documents";
      download = "${config.eownerdead.imperm.path}/downloads";
      music = "${config.eownerdead.imperm.path}/music";
      pictures = "${config.eownerdead.imperm.path}/pictures";
      publicShare = "${config.eownerdead.imperm.path}/public";
      templates = "${config.eownerdead.imperm.path}/templates";
      videos = "${config.eownerdead.imperm.path}/videos";
    };
  };
}
