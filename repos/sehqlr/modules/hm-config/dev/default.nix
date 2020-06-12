{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [ stack nixops python3.7-editorconfig ];

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  programs.jq.enable = true;

  programs.emacs.enable = true;
  services.emacs.enable = true;

  programs.kakoune.enable = true;
  programs.kakoune.config = {
    colorScheme = "solarized-dark";
    hooks = [{
        name = "WinCreate";
        option = "^[^*]+$";
        commands = "editorconfig-load";
    }];
    numberLines.enable = true;
    showWhitespace.enable = true;
    ui.enableMouse = true;
  };
  services.lorri.enable = true;

  home.file.".stack/config.yaml".source = ./stack-config.yaml;

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
      extraConfig = { init = { templateDir = "~/.config/git/template/"; }; };
    };
    ssh = {
      enable = true;
      matchBlocks = {
        "github" = {
          host = "github.com";
          user = "git";
        };
        "gitlab" = {
          host = "gitlab.com";
          user = "git";
        };
        "sr.ht" = { host = "*sr.ht"; };
        "bytes.zone" = {
          host = "git.bytes.zone";
          user = "git";
          port = 2222;
        };
      };
    };
  };
}
