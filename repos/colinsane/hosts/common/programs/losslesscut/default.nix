{ pkgs, ... }:
{
  sane.programs.losslesscut = {
    buildCost = 1;
    sandbox.wrapperType = "inplace";  # something's self referential, didn't check what.
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/from"  # videos from e.g. mobile phone
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    # sandbox.whitelistX = true;
    sandbox.mesaCacheDir = ".cache/losslesscut/mesa";  # TODO: is this the correct app-id?
    packageUnwrapped = pkgs.losslesscut.overrideAttrs (base: {
      extraMakeWrapperArgs = (base.extraMakeWrapperArgs or []) ++ [
        "--append-flags '--ozone-platform-hint=auto --ozone-platform=wayland --enable-features=WaylandWindowDecorations'"
      ];
    });
  };
}
