{ pkgs, ... }:
{
  sane.programs.sponge = {
    # packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.moreutils "sponge";
    # actually, don't build all of moreutils, to dodge the runtime dep on perl.
    packageUnwrapped = pkgs.moreutils.overrideAttrs (base: {
      makeFlags = (base.makeFlags or []) ++ [
        "BINS=sponge"
        "MANS=sponge.1"
        "PERLSCRIPTS=sponge"  #< Makefile errors if empty, but this works :)
      ];
      buildInputs = [];  #< sponge has no runtime perl deps => disable
    });

    sandbox.autodetectCliPaths = "existingFileOrParent";
  };
}
