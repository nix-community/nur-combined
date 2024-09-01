{ pkgs, ... }:
{
  home.packages = [ pkgs.tealdeer ];
  programs.navi = {
    enable = true;
    package = pkgs.navi.override (old: {
      rustPlatform = old.rustPlatform // {
        buildRustPackage = args: old.rustPlatform.buildRustPackage (args // {
          src = pkgs.fetchFromGitHub {
            owner = "denisidoro";
            repo = "navi";
            rev = "0a1413faa8fa23b9a1691d57178009342eda7f50";
            sha256 = "sha256-h7lF+jvrwjiMMmaqOGifJnBbTgjCK0WW2yocq7vO7zU=";
          };
          cargoHash = "sha256-dvsDytMZmdHkaJc2fYDTfdIPymnPFsdtC0LMpTElAZA=";
        });
      };
    });
    settings = {
      style = {
        tag = {
          width_percentage = 15;
        };
        comment = {
          width_percentage = 45;
        };
        snippet = {
          width_percentage = 40;
        };
      };
      search = {
        tags = "common,linux";
      };
      client = {
        tealdeer = true;
      };
    };
  };
  programs.fish.functions.naviq = {
    body = ''
      set -l match (navi --print -q "^$argv[1]," $argv[2..])
      if test -z "$match"
        return
      end
      commandline -p "$match"
      commandline -f repaint
    '';
    wraps = "navi";
  };
}
