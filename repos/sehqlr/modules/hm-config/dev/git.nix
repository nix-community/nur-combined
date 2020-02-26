{ config, lib, pkgs, ... }:
{
    xdg.configFile."git/template".source = ./template;
    programs = {
      git = {
        enable = true;
        aliases = {
          graph = "log --graph --oneline --decorate";
          staged = "diff --cached";
          uncommit = "reset --soft HEAD^";
          undo = "checkout --";
          unstage = "reset";
        };
        ignores = [ "result" "*~" ".#*" ];
        signing.key = "hey@samhatfield.me";
        signing.signByDefault = true;
        userEmail = "hey@samhatfield.me";
        userName = "sehqlr";
        extraConfig = {
          init = {
            templateDir = "~/.config/git/template/";
          };
        };
      };
      ssh = {
        enable = true;
        matchBlocks = {
          "github" = {
            host = "github.com";
            user = "git";
            identityFile = "~/.ssh/github_temp";
          };
          "gitlab" = {
            host = "gitlab.com";
            user = "git";
            identityFile = "~/.ssh/gitlab";
          };
          "sr.ht" = {
            host = "*sr.ht";
            identityFile = "~/.ssh/sr.ht";
          };
          "bytes.zone" = {
            host = "git.bytes.zone";
            user = "git";
          };
        };
      };
    };
}
