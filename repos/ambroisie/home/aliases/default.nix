{ config, lib, ... }:
let
  cfg = config.my.home.aliases;
in
{
  options.my.home.aliases = with lib; {
    enable = my.mkDisableOption "shell aliases configuration";
  };

  config = lib.mkIf cfg.enable {
    home = {
      shellAliases = {
        # I like pretty colors
        diff = "diff --color=auto";
        grep = "grep --color=auto";
        egrep = "egrep --color=auto";
        fgrep = "fgrep --color=auto";
        ls = "ls --color=auto";

        # Well-known ls aliases
        l = "ls -alh";
        ll = "ls -l";
      };
    };
  };
}
