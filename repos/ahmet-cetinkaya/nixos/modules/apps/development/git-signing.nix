{
  home-manager.sharedModules = [
    ({pkgs, ...}: {
      programs.git.settings = {
        user.signingKey = "E52DA6A2FA3247526E01B7010E4139BDC3163C05";
        commit.gpgSign = true;
        tag.gpgSign = true;
        gpg.program = "gpg2";
      };

      home.packages = with pkgs; [
        gnupg
        pinentry-tty
      ];

      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
        enableSshSupport = true;
      };
    })
  ];
}
