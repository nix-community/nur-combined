{

  flake.modules.nixos.git =
    { config, pkgs, ... }:
    {
      programs.git = {
        enable = true;
      };
      systemd.tmpfiles.rules = [
        "L+ /home/${config.identity.user}/.gitconfig - - - - ${pkgs.writeText "gitconfig" ''
          [credential]
            helper = cache --timeout 7200
            helper = oauth
          [credential "https://git.nyaw.xyz"]
            oauthClientId = a4792ccc-144e-407e-86c9-5e7d8d9c3269
            oauthAuthURL = /login/oauth/authorize
            oauthTokenURL = /login/oauth/access_token
        ''}"

      ];
    };
}
