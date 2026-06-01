{ config, lib, pkgs, ... }:

let
  inherit (builtins) listToAttrs;
  inherit (config.programs) delta;
  inherit (lib) getExe getExe' mkForce nameValuePair range;
  inherit (pkgs.writers) writeTOML;

  identity = import ../library/identity.lib.nix { inherit lib; };
  palette = import ../library/palette.lib.nix { inherit lib pkgs; };
in
{
  home.packages = with pkgs; [
    git-absorb
    git-filter-repo
    git-remote
    jjui
    tig
  ];

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
    options =
      with palette.hex; {
        file-renamed-label = "moved:";
        line-numbers-left-format = "{nm:>1} ";
        line-numbers-left-style = "${white-dark} bold";
        line-numbers-minus-style = "${vermilion-dark} bold";
        line-numbers-plus-style = "${teal-dark} bold";
        line-numbers-right-format = "{np:>1}▐";
        line-numbers-right-style = "${white-dark} bold";
        line-numbers-zero-style = "${white-dark} bold";
        minus-emph-style = "${vermilion-dark-contrast-minimum} ${vermilion-dark}";
        minus-empty-line-marker-style = "normal ${vermilion-dark}";
        minus-non-emph-style = "${white-dim} dim";
        minus-style = "${vermilion-dark-contrast-minimum} ${vermilion-dark}";
        plus-emph-style = "syntax ${teal-dark}";
        plus-empty-line-marker-style = "normal ${teal-dark}";
        plus-non-emph-style = "syntax dim";
        plus-style = "syntax ${teal-dark}";
        syntax-theme = "Monokai Extended";
        whitespace-error-style = "reverse white";
        wrap-max-lines = "unlimited";
        zero-style = "syntax dim";

        full = {
          file-style = "white bold";
          file-decoration-style = "omit";
          hunk-header-style = "omit";
          line-numbers = true;
        };
      };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;

    signing.key = identity.openpgp.id;

    attributes = [
      "* merge=mergiraf"
      "*.gif diff=image"
      "*.jpg diff=image"
      "*.png diff=image"
      "*.sfdir/*.glyph filter=sfd"
    ];

    ignores = [
      ".direnv/"
      ".envrc"
      ".envrc.gemset.nix"
      ".envrc.nix"
      ".local.justfile"
      ".Trash-*"
      ".venv/"
      ".vscode/"
      "result"
    ];

    iniContent.core.pager = mkForce "${getExe delta.finalPackage} --color-only --features full"; # Set feature

    settings = {
      branch.sort = "-committerdate";
      commit.verbose = true;
      core.autocrlf = "input";
      diff.algorithm = "histogram";
      diff.mnemonicPrefix = true;
      diff.renames = true;
      fetch.all = true;
      fetch.prune = true;
      fetch.pruneTags = true;
      init.defaultBranch = "main";
      merge.commit = false;
      merge.conflictStyle = "diff3";
      merge.tool = "code";
      push.followTags = true;
      rebase.autoSquash = true;
      rebase.autoStash = true;
      rebase.updateRefs = true;
      rerere.autoupdate = true;
      rerere.enabled = true;
      tag.sort = "version:refname";
      user.name = identity.name.long;
      user.email = identity.email;

      alias = {
        diff-image = "!f() { cd -- \"\${GIT_PREFIX:-.}\"; GIT_DIFF_IMAGE_ENABLED=1 git diff \"$@\"; }; f";
        ff = "merge --ff-only";
        kitty = "difftool --tool=kitty --no-symlinks --dir-diff";
        puff = "pull --ff-only";
        recent = "!git --no-pager log --max-count 8 --pretty=tformat:\"%w($(tput cols),0,8)%C(cyan)%h%Creset %C(yellow)%cr:%C(magenta)%d%Creset %s\"";
      };

      diff.anvil.textconv = getExe pkgs.git-diff-minecraft;
      diff.image.command = getExe' pkgs.git-diff-image "git_diff_image";
      difftool = { prompt = false; trustExitCode = true; };

      filter.sfd.clean = "sed '/^Flags:/s/[OS]//g'"; # Unset (O)pen, (S)elected

      tig = {
        line-graphics = "utf-8";
        main-view-date = "custom";
        main-view-date-format = "%F %H:%M";
        main-view-date-use-author = true;
        main-view-id-display = true;
        show-changes = false;
        tab-size = 4;
        truncation-delimiter = "utf-8";
        vertical-split = false;
        color = (listToAttrs (map (n: nameValuePair "palette-${toString n}" "color8 default") (range 0 13))) // {
          author = "color8 default";
          cursor = "black magenta bold";
          graph-commit = "magenta default";
          date = "yellow default";
          id = "cyan default";
          main-head = "magenta default bold";
          main-local-tag = "green default";
          main-ref = "magenta default";
          main-remote = "blue default";
          main-tag = "green default";
          main-tracked = "blue default bold";
          search-result = "black white bold";
          title-blur = "white black";
          title-focus = "white black bold";
        };
        bind.generic = "d @kitten @ launch --self --type=overlay --title=current --cwd=current --env DELTA_PAGER='less -+F' git show %(commit)"; # Pending jonas/tig#542
      };
    };
  };

  programs.jujutsu = {
    enable = true;

    settings = {
      user.name = identity.name.long;
      user.email = identity.email;

      signing.backend = "gpg";

      merge-tools = {
        delta = {
          program = getExe delta.finalPackage;
          diff-args = [ "--features" "full" "$left" "$right" ];
        };
      };

      # Reference: https://github.com/jj-vcs/jj/blob/main/cli/src/config/templates.toml
      templates = {
        draft_commit_description = "concat(builtin_draft_commit_description, surround(\"JJ:\\n\", '', indent('JJ:     ', diff.git())))";
      };

      # Reference: https://github.com/jj-vcs/jj/blob/main/cli/src/config/templates.toml
      template-aliases = {
        description_placeholder = "label(\"description placeholder\", \"WIP\")";
        empty_commit_marker = "label(\"empty\", \"✓\")";
        "format_short_signature(s)" = "coalesce(s.name(), s.email(), name_placeholder)";
        "format_short_signature_oneline(s)" = "coalesce(s.name(), s.email(), name_placeholder)";
      };

      ui = {
        diff-formatter = mkForce /* See nix-community/home-manager#8101 */ "delta";
        editor = getExe pkgs.jj-dynamic-default-description;
      };

      # Reference: https://github.com/jj-vcs/jj/blob/main/cli/src/config/colors.toml
      colors = rec {
        change_id = "default";
        commit_id = "bright black";
        author = "default";
        committer = author;
        timestamp = "bright black";
        bookmark = "blue";
        bookmarks = bookmark;
        local_bookmarks = bookmark;
        remote_bookmarks = bookmark;
        tag = bookmark;
        tags = tag;
        "description placeholder" = { fg = "red"; italic = true; };
        "empty description placeholder" = { fg = "bright black"; italic = true; };

        "working_copy commit_id" = commit_id;
        "working_copy change_id" = change_id;
        "working_copy timestamp" = timestamp;
        "working_copy bookmark" = bookmark;
        "working_copy bookmarks" = bookmarks;
        "working_copy local_bookmarks" = local_bookmarks;
        "working_copy remote_bookmarks" = remote_bookmarks;
        "working_copy tag" = tag;
        "working_copy tags" = tags;
        "working_copy description" = "magenta";
        "working_copy description placeholder" = { fg = "magenta"; italic = true; };
        "working_copy empty description placeholder" = { fg = "bright black"; italic = true; };

        "diff empty" = "cyan";
        "diff binary" = "cyan";
        "diff hunk_header" = "cyan";
        "diff modified" = "cyan";
        "diff untracked" = "yellow";
        "diff renamed" = "cyan";

        "node working_copy" = "magenta";
      };

      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "closest_pushable(to)" = "heads(::to & mutable() & ~description(exact:'') & (~empty() | merges()))";
        "local()" = "description(glob:'⚠️*')";
      };

      git = {
        private-commits = "local()";
      };

      aliases = {
        consume = [ "squash" "--interactive" "--into" "@" "--from" ];
        eject = [ "squash" "--interactive" "--from" "@" "--into" ];
        recent = [ "log" "--limit" "8" "--template" "builtin_log_oneline" ];
        tug = [ "bookmark" "move" "--from" "closest_bookmark(@)" "--to" "closest_pushable(@)" ];
      };

      "--scope" = [
        {
          "--when".commands = [ "log" ];
          template-aliases = {
            "format_timestamp(t)" = "t.local().format(\"%F\")";
          };

          colors = rec {
            change_id = "bright black";
            author = "bright black";
            committer = author;
            empty = "bright black";

            "working_copy change_id" = change_id;
            "working_copy author" = author;
            "working_copy committer" = committer;
            "working_copy empty" = empty;
          };
        }
      ];
    };
  };

  programs.mergiraf = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
  };

  # Reference: https://github.com/idursun/jjui/blob/main/internal/config/default/config.toml
  xdg.configFile."jjui/config.toml".source = writeTOML "jjui-config" {
    preview.show_at_start = true;

    # Reference: https://github.com/idursun/jjui/blob/main/internal/config/default/default_dark.toml
    ui.colors = with palette.hex; {
      "revisions selected" = { fg = "white"; bg = white-dark; };
    };

    keys = {
      preview = {
        half_page_down = [ "pgdown" ];
        half_page_up = [ "pgup" ];
      };
    };

    custom_commands = {
      tug = { args = [ "tug" ]; key = [ "alt+t" ]; };
    };

    revisions.revset = "::(present(@) | ancestors(immutable_heads().., 2) | trunk() | tags() | bookmarks() | remote_bookmarks())";
  };
}
