{ ... }:
{
  sane.programs.ripgrep = {
    sandbox.method = "landlock";
    sandbox.wrapperType = "wrappedDerivation";  # slow to build
    sandbox.autodetectCliPaths = true;
    sandbox.whitelistPwd = true;

    # .ignore file is read by ripgrep (rg), silver searcher (ag), maybe others.
    # ignore translation files by default when searching, as they tend to have
    # a LOT of duplicate text.
    fs.".ignore".symlink.text = ''
      po/
    '';
  };
}
