{
  config,
  pkgs,
  lib,
  ...
}:

let
  userEmail = "d.ol.rod@tutanota.com";
  userName = "P.";
  userInfo = {
    email = userEmail;
    name = userName;
  };
  gpgKey = "F90110C7";
  inherit (pkgs) apep gorin gnumake;

in
{
  home.packages = [
    apep
    gorin
    gnumake
  ];
  programs = {
    git = {
      # FIXME: Make me private
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user = userInfo;
      };
      ignores = (lib.optionals config.programs.jujutsu.enable) [ ".jj" ] ++ [
        ".direnv/"
        ".devenv/"
      ];
      signing = {
        key = gpgKey;
        signByDefault = true;
      };
    };
    jujutsu = {
      enable = true;
      settings = {
        user = userInfo;
        ui.paginate = "never";
        signing = {
          behavior = "own";
          backend = "gpg";
          key = gpgKey;
        };
      };
    };
    gpg.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    ssh = {
      enable = true;
      matchBlocks =
        let
          idkey = user: {
            inherit user;
            identityFile = "${config.home.homeDirectory}/.ssh/Keys/id";
          };
        in
        {
          "github.com" = idkey "git";
          "gitlab.com" = idkey "git";
          "codeberg.org" = idkey "git";
          "git.sr.ht" = idkey "git";
          "hg.sr.ht" = idkey "hg";
        };
    };
  };
  services = {
    gpg-agent = {
      enable = true;
      # FIXME: Check my purpose
      enableScDaemon = false;
      pinentry.package = pkgs.pinentry-curses;
    };
  };
}
