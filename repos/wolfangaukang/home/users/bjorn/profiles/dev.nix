{
  inputs,
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
  imports = [ "${inputs.self}/home/modules/dprint.nix" ];

  home.packages = [
    apep
    gorin
    gnumake
  ];
  programs = {
    dprint = {
      enable = true;
      settings = {
        markdown = {
          lineWidth = 120;
          textWrap = "always";
        };
        excludes = [
          "**/*-lock.json"
        ];
        plugins = [ "https://plugins.dprint.dev/markdown-0.20.0.wasm" ];
      };
    };
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
        format = "openpgp"; # NOTE: In 25.05, this is null
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
      enableScDaemon = false;
      pinentry.package =
        if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
    };
  };
}
