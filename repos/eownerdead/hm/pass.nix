{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./gpg.nix ];

  options.eownerdead.pass = {
    enable = lib.mkEnableOption "Enable pass";
    git.enable = lib.mkEnableOption "Enable git integration";
  };

  config = lib.mkIf config.eownerdead.pass.enable {
    eownerdead.gpg.enable = true;

    programs = {
      password-store = {
        enable = true;
        package = pkgs.pass-wayland.withExtensions (
          p: with p; [
            pass-otp
            pass-import
          ]
        );
        settings.PASSWORD_STORE_DIR = "${config.eownerdead.imperm.dataHome}/password-store";
      };
      git.settings.credential.helper = lib.mkIf config.eownerdead.pass.git.enable [
        "!${pkgs.pass-git-helper}/bin/pass-git-helper $@"
      ];
    };
    services.pass-secret-service.enable = true;
  };
}
