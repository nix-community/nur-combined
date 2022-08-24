{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.defaultajAgordoj.cli;
  settings = import ./settings.nix { inherit pkgs; };

in
{
  meta.maintainers = [ wolfangaukang ];

  options.defaultajAgordoj.cli = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables the CLI tools, plus the common Git, GPG, Neovim, Pass and SSH settings.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = settings.packages.cli;
      programs = {
        git = {
          enable = true;
          extraConfig.init.defaultBranch = "main";
          signing = {
            key = "F90110C7";
            signByDefault = true;
          };
          userName = "P. R. d. O.";
          userEmail = "d.ol.rod@tutanota.com";
        };
        gpg.enable = true;
        neovim = {
          enable = true;
          package = settings.neovim.package;
          plugins = settings.neovim.plugins;
          viAlias = true;
        };
        ssh = {
          enable = true;
          matchBlocks = {
            surtsey = {
              hostname = "192.168.8.203";
              user = "marx";
              identityFile = ["~/.ssh/surtsey"];
            };
          };
        };
      };
      services.gpg-agent = {
        enable = true;
        enableScDaemon = false;
        pinentryFlavor = "curses";
      };
    }
  ]);
}
