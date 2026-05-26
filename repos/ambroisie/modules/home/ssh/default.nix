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
        enableDefaultConfig = false;

        includes = [
          # Local configuration, not-versioned
          "config.local"
        ];

        settings = {
          "github.com" = {
            HostName = "github.com";
            IdentityFile = "~/.ssh/shared_rsa";
            User = "git";
          };

          "gitlab.com" = {
            HostName = "gitlab.com";
            IdentityFile = "~/.ssh/shared_rsa";
            User = "git";
          };

          "git.sr.ht" = {
            HostName = "git.sr.ht";
            IdentityFile = "~/.ssh/shared_rsa";
            User = "git";
          };

          "git.belanyi.fr" = {
            HostName = "git.belanyi.fr";
            IdentityFile = "~/.ssh/shared_rsa";
            User = "git";
          };

          porthos = {
            HostName = "37.187.146.15";
            IdentityFile = "~/.ssh/shared_rsa";
            User = "ambroisie";
          };

          # `*` is automatically made the last match block by the module
          "*" = {
            AddKeysToAgent = "yes";
          };
        };
      };
    }

    (lib.mkIf cfg.mosh.enable {
      home.packages = [
        cfg.mosh.package
      ];
    })
  ]);
}
