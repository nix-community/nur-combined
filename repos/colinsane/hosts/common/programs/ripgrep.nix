{ ... }:
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
    fs.".ignore".symlink.text = ''
      po/
    '';
  };
}
