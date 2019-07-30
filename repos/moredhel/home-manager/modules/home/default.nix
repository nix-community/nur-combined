{ config ? {}, lib, pkgs, ... }:
with lib;

let
  cfg = config.programs.base;
  kubectx = pkgs.nur.repos.moredhel.kubectx;
in
  {
    options.programs.base = with types; {
      enable = mkOption {
        type = bool;
        default = false;
      };

    };
    config = mkIf cfg.enable {
      home.keyboard = {
        layout = "dvorak";
      };

      services.syncthing.enable = true;

      programs.bash = {
        enable = true;
        historyControl = [
          "erasedups"
          "ignoredups"
          "ignorespace"
          ];
          shellAliases = {
            g = "git";
            k = "${pkgs.kubectl}/bin/kubectl";
            ktx = "${kubectx}/bin/kubectx";
            kns = "${kubectx}/bin/kubens";
            cat = "${pkgs.bat}/bin/bat";
            emacs = "emacsclient --socket /tmp/emacs1000/server -c -n";
            vim = "emacsclient --socket /tmp/emacs1000/server -nw"; # TODO: see if it is worth changing...
    };
    enableAutojump = true;
    sessionVariables = {
      PAGER = "less";
    };
    initExtra = ''
      # extend PATH
      PATH=$PATH:./node_modules/.bin:~/bin
    '';
  };

  programs.git = {
    enable = true;
    userName = "Hamish Hutchings";
    userEmail = "moredhel@aoeu.me";
    signing = {
      signByDefault = false;
      key = "A1390B0803E1F325433A18EF80784F5CAD59A3F4";
    };
    aliases = {
      co = "checkout";
      s = "status";
      d = "diff --color";
      a = "add";
      cm = "commit";
      l = "log --color";
      b = "branch";
      f = "flow";
    };
    extraConfig = ''
      [color]
      ui = true

      [merge]
      conflictstyle = diff3
      tool = vimdiff

      [push]
      default = simple

      [url "ssh://git@github.com/"]
      insteadOf = https://github.com/
    '';
  };

  # fix for failing manpage build
  manual.manpages.enable = false;
  programs.home-manager = {
    enable = true;
    path = https://github.com/rycee/home-manager/archive/master.tar.gz;
  };
};
}
