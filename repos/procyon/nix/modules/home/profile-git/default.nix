# SPDX-FileCopyrightText: 2023 Sridhar Ratnakumar <srid@srid.ca>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, ... }:
{
  home = {
    packages = with pkgs; [ git-crypt ];
    shellAliases = {
      g = "git";
      lg = "lazygit";
    };
  };

  programs = {
    lazygit.enable = true;
    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-dash
        gh-markdown-preview
      ];
    };
    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.gitAndTools.gitFull;
      extraConfig = {
        pull.rebase = true;
        commit.gpgsign = true;
        rebase.autostash = true; # https://stackoverflow.com/a/30209750/22859493
        init.defaultBranch = "main";
        diff.sopsdiffer.textconv = "${pkgs.sops}/bin/sops -d --config /dev/null";
        user = with flake.config.people; {
          name = users.${myself}.name;
          email = users.${myself}.email;
          signingkey = users.${myself}.keys.gpg;
        };
        alias = {
          a = "add";
          co = "checkout";
          ci = "commit";
          cia = "commit --amend";
          d = "diff";
          l = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          plog = "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
          tlog = "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
          rank = "shortlog -sn --no-merges";
          rb = "rebase";
          st = "status";
          sw = "switch";
          b = "branch";
          ps = "push";
          pl = "pull";
        };
      };
    };
  };
}
