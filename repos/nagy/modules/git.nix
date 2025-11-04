{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.git;
in
{
  imports = [ ./shortcommands.nix ];

  environment.sessionVariables = {
    # cleaner git repos without the hooks
    GIT_TEMPLATE_DIR = pkgs.emptyDirectory.outPath;
  };

  programs.git = {
    config = {
      alias = {
        # c = "commit"; # in included git aliases
        # co = "checkout"; # in included git aliases
        cl = "clone";
        cl1 = "clone --depth 1";
        f = "fetch";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "lol --all";
      };
      # spend more time to produce a smaller diff
      # https://git-scm.com/docs/diff-config#Documentation/diff-config.txt-diffalgorithm
      diff.algorithm = "minimal";
      commit = {
        # Show my changes when writing the message
        verbose = true;
      };
      init = {
        defaultBranch = "master";
      };
      push = {
        default = "current";
      };
      pull.rebase = true;
      fetch.prune = true;
      include.path =
        let
          git-alias = pkgs.fetchFromGitHub {
            owner = "GitAlias";
            repo = "gitalias";
            rev = "ed036c1fd16c8e690329c594bc028f58c6e3b349";
            sha256 = "sha256-OtKdN4SeJSswtF3Uvs3cMZwTwpL2wEm4KU1iKmfEr30=";
          };
        in
        "${git-alias}/gitalias.txt";
      merge.conflictStyle = "diff3";
      gc = {
        auto = "0";
      };
      # https://baecher.dev/stdout/reproducible-git-bundles/
      # to make packs reproducible
      pack.threads = 1;
      # another attempt. untested.
      index.threads = 1;
      tar = {
        "tar.xz".command = "${pkgs.xz}/bin/xz -c";
        "tar.bz2".command = "${pkgs.bzip2}/bin/bzip2 -c";
        "tar.zst".command = "${pkgs.zstd}/bin/zstd -c";
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
      # To work around the workaround of CVE-2022-24765.
      # See https://github.com/NixOS/nixpkgs/issues/169193 for more
      safe.directory = "*";
      filter = {
        # use with `.gitattributes`
        # file content: *.sqlite3 filter=sqlite3-sql
        # more info https://github.com/theTaikun/SQLite-git-smudge-and-clean
        sqlite3-sql = {
          clean = "${pkgs.sqlite}/bin/sqlite3 %f .dump";
          smudge = toString (
            pkgs.writeShellScript "git-smudge-sqlite3" ''
              TMPFILE=$(mktemp)
              cat | ${pkgs.sqlite}/bin/sqlite3 "$TMPFILE"
              cat -- "$TMPFILE"
              rm -f -- "$TMPFILE"
            ''
          );
        };
        jq = {
          clean = "${pkgs.jq}/bin/jq --sort-keys";
        };
        # without this, restic snapshots output is not deterministic
        # jq-restic = {
        #   clean = "${pkgs.jq}/bin/jq --sort-keys 'sort_by(.id)'";
        # };
        # taplo-fmt = {
        #   clean = "${pkgs.taplo}/bin/taplo fmt -";
        # };
        # ruff-format = {
        #   clean = "ruff format -";
        # };
      };
      diff = {
        pdf = {
          textconv = pkgs.writeShellScript "pdftostdout" ''
            exec ${pkgs.poppler_utils}/bin/pdftotext -layout "$@" -
          '';
          binary = true;
        };
        exif = {
          textconv = lib.getExe pkgs.exiftool;
          binary = true;
        };
        tar = {
          textconv = "${pkgs.gnutar}/bin/tar -tvf";
          binary = true;
        };
        tar-gz = {
          textconv = "${pkgs.gnutar}/bin/tar -tvzf";
          binary = true;
        };
        tar-bz2 = {
          textconv = "${pkgs.gnutar}/bin/tar -tvjf";
          binary = true;
        };
        tar-xz = {
          textconv = "${pkgs.gnutar}/bin/tar -tvJf";
          binary = true;
        };
        tar-zstd = {
          textconv = "${pkgs.gnutar}/bin/tar --zstd -tvf";
          binary = true;
        };
        orgmode = {
          xfuncname = "^(\\*+.*)$";
        };
        lisp = {
          xfuncname = "^(\\(.*)$";
        };
      };
    };
  };

  environment.etc.gitattributes = lib.mkIf cfg.enable {
    text = ''
      *.pdf diff=pdf
      *.png diff=exif
      *.jpg diff=exif
      *.jpeg diff=exif
      *.gif diff=exif
      *.tar diff=tar
      *.tar.gz diff=tar-gz
      *.tgz diff=tar-gz
      *.tar.bz2 diff=tar-bz2
      *.tar.xz diff=tar-xz
      *.tar.zst diff=tar-zstd
      *.json filter=jq
      *.restic.json filter=jq-restic
      # *.toml filter=taplo-fmt
      # *.py filter=ruff-format
      *.org  diff=orgmode
      *.hy   diff=lisp
      *.el   diff=lisp
      *.lisp diff=lisp
      ### git builtin
      *.md    diff=markdown
      *.rs    diff=rust
      *.c     diff=cpp
      *.h     diff=cpp
      *.c++   diff=cpp
      *.h++   diff=cpp
      *.cpp   diff=cpp
      *.hpp   diff=cpp
      *.cc    diff=cpp
      *.hh    diff=cpp
      *.go    diff=golang
      *.py    diff=python
      *.scm   diff=scheme
      *.sh    diff=bash
      *.tex   diff=tex
      *.bib   diff=bibtex
      *.css   diff=css
    '';
  };

  nagy.shortcommands.commands = lib.mkIf cfg.enable {
    g = [ "git" ];
    gcl = [
      "git"
      "clone"
    ];
    gcl1 = [
      "git"
      "clone"
      "--depth=1"
    ];
    gcl2 = [
      "git"
      "clone"
      "--depth=2"
    ];
    gf = [
      "git"
      "fetch"
    ];
    gfa = [
      "git"
      "fetch"
      "--all"
    ];
    gfp = [
      "git"
      "fetch"
      "--prune"
    ];
    gt = [
      "git"
      "tag"
    ];
    gtl = [
      "git"
      "tag"
      "--list"
    ];
    gts = [
      "git"
      "tags"
    ];
    gp = [
      "git"
      "push"
    ];
    gpf = [
      "git"
      "push"
      "--force"
    ];
    gpl = [
      "git"
      "pull"
    ];
  };
}
