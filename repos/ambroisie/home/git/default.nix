{ config, pkgs, lib, ... }:
let
  cfg = config.my.home.git;
in
{
  options.my.home.git = with lib.my; {
    enable = mkDisableOption "git configuration";
  };

  config.programs.git = lib.mkIf cfg.enable {
    enable = true;

    # Who am I?
    userEmail = "bruno@belanyi.fr";
    userName = "Bruno BELANYI";

    # I want the full experience
    package = pkgs.gitAndTools.gitFull;

    aliases = {
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "lol --all";
      assume = "update-index --assume-unchanged";
      unassume = "update-index --no-assume-unchanged";
      assumed = "!git ls-files -v | grep ^h | cut -c 3-";
      pick = "log -p -G";
      push-new = "!git push -u origin "
        + ''"$(git branch | grep '^* ' | cut -f2- -d' ')"'';
    };

    lfs.enable = true;

    # There's more
    extraConfig = {
      # Makes it a bit more readable
      blame = {
        coloring = "repeatedLines";
        markIgnoredLines = true;
        markUnblamables = true;
      };

      # I want `pull --rebase` as a default
      branch = {
        autosetubrebase = "always";
      };

      # Shiny colors
      color = {
        branch = "auto";
        diff = "auto";
        interactive = "auto";
        status = "auto";
        ui = "auto";
      };

      # Pretty much the usual diff colors
      "color.diff" = {
        commit = "yellow";
        frag = "cyan";
        meta = "yellow";
        new = "green";
        old = "red";
        whitespace = "red reverse";
      };

      "color.diff-highlight" = {
        oldNormal = "red bold";
        oldHighlight = "red bold 52";
        newNormal = "green bold";
        newHighlight = "green bold 22";
      };

      commit = {
        # Show my changes when writing the message
        verbose = true;
      };

      diff = {
        # Usually leads to better results
        algorithm = "patience";
      };

      fetch = {
        # I don't want hanging references
        prune = true;
        pruneTags = true;
      };

      init = {
        defaultBranch = "main";
      };

      pager =
        let
          diff-highlight = "${pkgs.gitAndTools.gitFull}/share/git/contrib/diff-highlight/diff-highlight";
        in
        {
          diff = "${diff-highlight} | less";
          log = "${diff-highlight} | less";
          show = "${diff-highlight} | less";
        };

      pull = {
        # Avoid useless merge commits
        rebase = true;
      };

      push = {
        # Just yell at me instead of trying to be smart
        default = "simple";
      };

      rebase = {
        # Why isn't it the default?...
        autoSquash = true;
        autoStash = true;
      };
    };

    # Multiple identities
    includes = [
      { path = ./epita.config; condition = "gitdir:~/git/EPITA/"; }
    ];

    ignores =
      let
        inherit (builtins) readFile;
        inherit (lib) filter hasPrefix splitString;
        readLines = file: splitString "\n" (readFile file);
        removeComments = filter (line: line != "" && !(hasPrefix "#" line));
        getPaths = file: removeComments (readLines file);
      in
      getPaths ./default.ignore;
  };
}
