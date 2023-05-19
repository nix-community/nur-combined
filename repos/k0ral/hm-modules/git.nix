{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let
  cfg = config.module.git;
in {
  options.module.git = {
    enable = mkEnableOption "Git module";
    username = mkOption {
      type = types.str;
    };
    email = mkOption {
      type = types.str;
    };
    extraConfig = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ tig ];

    programs = {
      gh.enable = true;
      gh.settings.git_protocol = "ssh";
      git = {
        enable = true;
        userEmail = cfg.email;
        userName = cfg.username;
        aliases = {
          ci = "commit";
          co = "checkout";
          ls = "log --date=short --graph --pretty=format:'%Cred%h %C(bold blue)%cn%Creset %cd %C(yellow)%d %C(bold white)%s'";
          st = "! gitui";
          glog = "! tig";
          unadd = "reset HEAD";
          delete-merged = "!git branch --merged master | egrep -v \"(^\\*|^  master$)\" | xargs git branch --delete";
          fixup = "! git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit -p --fixup";
        };
        delta = {
          enable = true;
          options = {
            features = "side-by-side line-numbers decorations";
            whitespace-error-style = "22 reverse";
            decorations = {
              commit-decoration-style = "bold yellow box ul";
              file-style = "bold yellow ul";
              file-decoration-style = "none";
            };
          };
        };
        difftastic = {
          enable = false;
          background = "dark";
        };
        extraConfig = {
          color = {
            ui = "auto"; # covers diff = true, status = auto, branch = auto
            interactive = "auto";
          };
          core = {
            # editor = "neovide --nofork +startinsert";
            editor = "nvim +startinsert";
          };
          commit = {
            template = "~/.config/git/gitmessage";
            verbose = true;
          };
          push = {
            default = "simple";
          };
          pull = {
            ff = "only";
            rebase = true;
          };
          merge = {
            tool = "nvimdiff";
          };
          mergetool = {
            nvimdiff = {
              cmd = "nvim -d $LOCAL $BASE $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
            };
          };
          rebase = {
            autosquash = true;
          };
          diff = {
            noprefix = true;
          };
        } // cfg.extraConfig;
      };
      gitui.enable = true;
    };

    xdg.configFile = {
      "git/gitmessage".text = ''

        # 👆 <type>(<optional scope>): <subject>
        # Type: build | chore | ci | docs | feat | fix | perf | refactor | revert | style | test
        # Subject: imperative, start upper case, don't end with a period

        # <BLANK LINE>
        # 👇 Body: Explain *what* and *why* (not *how*).
      '';
    };
  };
}
