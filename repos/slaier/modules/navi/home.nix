{ pkgs, ... }:
{
  home.packages = with pkgs; [ tealdeer yq-go ];
  programs.navi = {
    enable = true;
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
      set -l match (navi --print --tag-rules $argv[1],!osx,!bsd $argv[2..])
      if test -z "$match"
        return
      end
      commandline -p "$match"
      commandline -f repaint
    '';
    wraps = "navi";
  };
}
