{ pkgs, ... }:
{
  sane.programs.mercurial = {
    packageUnwrapped = pkgs.mercurialFull;
    sandbox.wrapperType = "inplace";  # etc/mercurial/hgrc refers to hg python-path (to define an extension)
    suggestedPrograms = [
      "colordiff"  #< optional, for my hgrc aliases
      "less"  #< TODO: this might be a missing dependency on the nix side of things?
    ];
    sandbox.net = "clearnet";
    sandbox.whitelistPwd = true;
    sandbox.whitelistSsh = true;
    sandbox.extraHomePaths = [
      # even with `whitelistPwd`, hg has to crawl *up* the path -- which isn't necessarily in the sandbox -- to locate the repo root.
      "dev"
      "ref"
    ];
    fs.".config/hg/hgrc".symlink.target = ./hgrc;
  };
}
