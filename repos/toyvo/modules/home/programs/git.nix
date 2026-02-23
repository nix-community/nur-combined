{ config, lib, ... }:
let
  cfg = config.programs.git;
in
{
  config = lib.mkIf cfg.enable {
    catppuccin = {
      delta = {
        enable = true;
        flavor = config.catppuccin.flavor;
      };
      lazygit = {
        enable = true;
        flavor = config.catppuccin.flavor;
        accent = config.catppuccin.accent;
      };
    };
    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;
      };
      git = {
        lfs.enable = true;
        settings = {
          pull.rebase = "true";
          rebase.autostash = "true";
          core.editor = "nvim";
          core.eol = "lf";
          core.autocrlf = "input";
          gpg.format = "ssh";
          init.defaultBranch = "main";
          url."git@github.com:".pushInsteadOf = "https://github.com/";
          alias = {
            a = "add";
            aa = "add -A";
            b = "branch";
            ba = "branch -a";
            c = "commit -m";
            ca = "commit -am";
            cam = "commit --amend --date=now";
            co = "checkout";
            cob = "checkout -b";
            sw = "switch";
            swc = "switch -c";
            s = "status -sb";
            po = "!git push -u origin $(git branch --show-current)";
            d = "diff";
            dc = "diff --cached";
            ignore = "update-index --assume-unchanged";
            unignore = "update-index --no-assume-unchanged";
            ignored = "!git ls-files -v | grep ^h | cut -c 3-";
            rbm = "!git fetch && git rebase origin/main";
            rbc = "-c core.editor=true rebase --continue";
          };
        };
      };
      lazygit.enable = true;
    };
  };
}
