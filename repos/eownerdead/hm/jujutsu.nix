{
  pkgs,
  lib,
  config,
  ...
}:
{

  options.eownerdead.jujutsu.enable = lib.mkEnableOption "Enable jujutsu";

  config = lib.mkIf config.eownerdead.jujutsu.enable {
    home.packages = with pkgs; [
      watchman
    ];

    programs = {
      jujutsu = {
        enable = true;
        package = pkgs.unstable.jujutsu;
        settings = {
          user = {
            email = "eownerdead@disroot.org";
            name = "EOWNERDEAD";
          };
          signing = {
            behavior = "drop";
            backend = "gpg";
          };
          git = {
            sign-on-push = true;
          };
          fsmonitor = {
            backend = "watchman";
            watchman = {
              register-snapshot-trigger = true;
            };
          };
          snapshot.auto-track = "none()";
        };
      };
      delta = {
        enable = true;
        enableJujutsuIntegration = true;
      };
    };
    home.persistence."/nix/persist".directories =
      lib.mkIf config.eownerdead.imperm.enable
        [
          ".config/jj" # Repository local configurations
        ];
  };
}
