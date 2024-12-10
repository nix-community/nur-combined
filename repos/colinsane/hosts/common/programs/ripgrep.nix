{ config, lib, ... }:
let
  cfg = config.sane.programs.ripgrep;
in
{
  sane.programs.ripgrep = {
    sandbox.autodetectCliPaths = "existing";
    sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      # let it follow symlinks to non-sensitive data
      ".persist/ephemeral"
      ".persist/plaintext"
    ];

    # .ignore file is read by ripgrep (rg), silver searcher (ag), maybe others.
    # ignore translation files by default when searching, as they tend to have
    # a LOT of duplicate text.
    # fs.".ignore".symlink.text = ''
    #   po/
    # '';
    # XXX(2024-12-08): rg crawls from pwd up to root checking for .ignore files,
    # however it does this *after* pwd has been dereferenced.
    # hence, if inside a persisted directory, it will crawl up through /mnt/persist/...
    # and never actually see the `.ignore` file in /home/colin.
    # instead: place the .ignore file in `/` and symlink it to ~ as a way to hack it into the sandbox
    fs.".ignore".symlink.target = "/.ignore";
  };

  sane.fs = lib.mkIf cfg.enabled {
    "/.ignore".symlink.text = ''
      po/
    '';
  };
}
