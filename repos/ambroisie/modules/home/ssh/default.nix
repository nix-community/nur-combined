{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.ssh;
in
{
  options.my.home.ssh = with lib; {
    enable = my.mkDisableOption "ssh configuration";

    mosh = {
      enable = my.mkDisableOption "mosh configuration";

      package = mkPackageOption pkgs "mosh" { };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.ssh = {
        enable = true;

        includes = [
          # Local configuration, not-versioned
          "config.local"
        ];

        matchBlocks = {
          "github.com" = {
            hostname = "github.com";
            identityFile = "~/.ssh/shared_rsa";
            user = "git";
          };

          "gitlab.com" = {
            hostname = "gitlab.com";
            identityFile = "~/.ssh/shared_rsa";
            user = "git";
          };

          "git.sr.ht" = {
            hostname = "git.sr.ht";
            identityFile = "~/.ssh/shared_rsa";
            user = "git";
          };

          "git.belanyi.fr" = {
            hostname = "git.belanyi.fr";
            identityFile = "~/.ssh/shared_rsa";
            user = "git";
          };

          porthos = {
            hostname = "37.187.146.15";
            identityFile = "~/.ssh/shared_rsa";
            user = "ambroisie";
          };
        };

        extraConfig = ''
          AddKeysToAgent yes
        '';
      };
    }

    (lib.mkIf cfg.mosh.enable {
      home.packages = [
        cfg.mosh.package
      ];
    })
  ]);
}
