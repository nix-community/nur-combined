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

  # currently in ~/.ssh/config because of uncertainty where this config should be
  # programs.ssh.extraConfig = ''
  #   Host github.com gitlab.com git.sr.ht codeberg.org
  #     User git
  #     IdentitiesOnly yes
  #     IdentityFile ~/.ssh/id_nagy
  #     # IdentityFile ''${XDG_RUNTIME_DIR}/ssh_id_nagy
  # '';

  programs.git = {
    enable = true;
    config = [
      {
        user.name = "Daniel Nagy";
        user.email = "danielnagy@posteo.de";
        user.signingkey = "/home/user/.ssh/id_nagy";
        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = pkgs.writeText "allowed_signers" ''
            danielnagy@posteo.de ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEVwcaKID2HpE4ZRYClT1URJCRXiSPsJR4FC5TwnlmCS
          '';
        };
        alias = {
          # c = "commit"; # in included git aliases
          # co = "checkout"; # in included git aliases
          cl = "clone";
          cl1 = "clone --depth 1";
          cl2 = "clone --depth 2";
          f = "fetch";
          lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
          lola = "lol --all";
        };
        # spend more time to produce a smaller diff
        # https://git-scm.com/docs/diff-config#Documentation/diff-config.txt-diffalgorithm
        diff.algorithm = "minimal";
        diff.external = "${pkgs.difftastic}/bin/difft";
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
        # Behaves badly when the remote does not exist
        # remote = {
        #   pushDefault = "origin";
        # };
        pull.rebase = true;
        fetch.prune = true;
        include.path =
          let
            git-alias = pkgs.fetchFromGitHub {
              owner = "GitAlias";
              repo = "gitalias";
              rev = "7653169af41a9fa93d6f5c5e2aedb4c7ce801840";
              sha256 = "sha256-nLXqRA6iB2ng/ESeu4dmccTNMg4wYPvBYJ2MlY1ci/A=";
            };
          in
          "${git-alias}/gitalias.txt";
        merge.conflictStyle = "diff3";
        gc = {
          auto = "0";
        };
        # https://baecher.dev/stdout/reproducible-git-bundles/
        # to make packs reproducible
        # pack.threads = 1;
        # # another attempt. untested.
        # index.threads = 1;
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
        };
        maintenance = {
          auto = false;
        };
        diff = {
          pdf = {
            textconv = pkgs.writeShellScript "pdftostdout" ''
              exec ${pkgs.poppler-utils}/bin/pdftotext -layout "$@" -
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
          # https://getsops.io/docs/#showing-diffs-in-cleartext-in-git
          sopsdiffer = {
            textconv = "${pkgs.sops}/bin/sops decrypt";
            binary = true;
          };
          orgmode = {
            xfuncname = "^(\\*+.*)$";
          };
          lisp = {
            xfuncname = "^(\\(.*)$";
          };
        };
        # lfs = {
        #   fetchexclude = "*";
        # };
      }
      {
        # url."git@github.com:".insteadOf = "https://github.com/";
        # url."git@gitlab.com:".insteadOf = "https://gitlab.com/";
        # url."git@git.sr.ht:".insteadOf = "https://git.sr.ht/";
        # url."git@codeberg.org:".insteadOf = "https://codeberg.org/";
        includeIf."hasconfig:remote.*.url:https://github.com/*/**".path =
          pkgs.writeText "gitconfig-includeIf" ''
            [commit]
                gpgsign = true
          '';
      }
    ];
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

}
