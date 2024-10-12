{ pkgs, config, ... }:
{
  programs = {
    password-store = {
      enable = true;
      package = pkgs.pass-wayland.withExtensions (
        p: with p; [
          pass-otp
          pass-import
        ]
      );
      settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/src/password-store";
    };
    git.extraConfig.credential.helper = [
      "!${pkgs.pass-git-helper}/bin/pass-git-helper $@"
    ];
  };

  services.pass-secret-service.enable = true;
}
