{ inputs, config, pkgs, ... }:

let
  userEmail = "d.ol.rod@tutanota.com";
  userName = "P.";
  mkdir-devshell = pkgs.writeScriptBin "mkdir-devshell" (builtins.readFile "${inputs.dotfiles}/bin/devshell/mkdir-devshell");

in
{
  home.packages = [ mkdir-devshell ];
  programs = {
    git = {
      # FIXME: Make me private
      inherit userName userEmail;
      enable = true;
      extraConfig.init.defaultBranch = "main";
      signing = {
        # FIXME: Make me private
        key = "F90110C7";
        signByDefault = true;
      };
    };
    mercurial = {
      # FIXME: Make me private
      inherit userName userEmail;
      enable = true;
      ignores = [
        ".direnv"
      ];
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
      pinentryPackage = pkgs.pinentry-curses;
    };
  };
}
