{ config, pkgs, lib, ... }:
let
  cfg = config.my.home.git;

  inherit (lib.my) mkMailAddress;
in
{
  options.my.home.git = with lib.my; {
    enable = mkDisableOption "git configuration";
  };

  config.home.packages = with pkgs; lib.mkIf cfg.enable [
    git-absorb
    git-revise
    tig
  ];

  config.programs.git = lib.mkIf cfg.enable {
    enable = true;

    # Who am I?
    userEmail = mkMailAddress "bruno" "belanyi.fr";
    userName = "Bruno BELANYI";

    # I want the full experience
    package = pkgs.gitFull;

    aliases = {
      git = "!git";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit --topo-order";
      lola = "lol --all";
      assume = "update-index --assume-unchanged";
      unassume = "update-index --no-assume-unchanged";
      assumed = "!git ls-files -v | grep ^h | cut -c 3-";
      pick = "log -p -G";
      push-new = "!git push -u origin "
        + ''"$(git branch | grep '^* ' | cut -f2- -d' ')"'';
    };

    lfs.enable = true;

    delta = {
      enable = true;

      options = {
        features = "diff-highlight decorations";

        # Less jarring style for `diff-highlight` emulation
        diff-highlight = {
          minus-style = "red";
          minus-non-emph-style = "red";
          minus-emph-style = "bold red 52";

          plus-style = "green";
          plus-non-emph-style = "green";
          plus-emph-style = "bold green 22";

          whitespace-error-style = "reverse red";
        };

        # Personal preference for easier reading
        decorations = {
          commit-style = "raw"; # Do not recolor meta information
          keep-plus-minus-markers = true;
          paging = "always";
        };
      };
    };

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

      merge = {
        conflictStyle = "zdiff3";
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

      url = {
        "git@gitea.belanyi.fr:" = {
          insteadOf = "https://gitea.belanyi.fr/";
        };

        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };

        "git@gitlab.com:" = {
          insteadOf = "https://gitlab.com/";
        };
      };
    };

    # Multiple identities
    includes = [
      {
        condition = "gitdir:~/git/EPITA/";
        contents = {
          user = {
            name = "Bruno BELANYI";
            email = mkMailAddress "bruno.belanyi" "epita.fr";
          };
        };
      }
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
