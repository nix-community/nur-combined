{ pkgs, ... }:
{
  sane.programs.errno = {
    # packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.moreutils "errno";
    # actually, don't build all of moreutils because not all of it builds for cross targets.
    packageUnwrapped = pkgs.moreutils.overrideAttrs (base: {
      makeFlags = (base.makeFlags or []) ++ [
        "BINS=errno"
        "MANS=errno.1"
        "PERLSCRIPTS=errno"  #< Makefile errors if empty, but this works :)
      ];
      buildInputs = [];  #< errno has no runtime perl deps, and they don't cross compile, so disable them.
    });

  };
}
