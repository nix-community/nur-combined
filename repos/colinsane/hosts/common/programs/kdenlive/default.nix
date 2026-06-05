{ pkgs, ... }:
{
  sane.programs.kdenlive = {
    buildCost = 1;

    packageUnwrapped = pkgs.kdePackages.kdenlive;
    # packageUnwrapped = pkgs.kdePackages.kdenlive.overrideAttrs (base: {
    #   qtWrapperArgs = base.qtWrapperArgs ++ [
    #     "--set QP_QPA_PLATFORM wayland"
    #   ];
    # });

    sandbox.extraHomePaths = [
      "Music"
      "Pictures/from"  # e.g. Videos taken from my phone
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # notifications
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    # sandbox.whitelistX = true;  #< or run with `QT_QPA_PLATFORM=wayland`, without X(wayland)
  };
}
