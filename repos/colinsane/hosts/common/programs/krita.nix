{ ... }:
{
  sane.programs.krita = {
    buildCost = 1;
    sandbox.whitelistWayland = true;
    sandbox.whitelistX = true;
    sandbox.autodetectCliPaths = "existing";
    sandbox.extraHomePaths = [
      "dev"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "ref"
      "tmp"
    ];

    suggestedPrograms = [
      "xwayland"  #< XXX(2024-11-10): does not start without X(wayland); not even with QT_QPA_PLATFORM=wayland. see e.g. <https://discuss.kde.org/t/is-there-any-plans-to-add-wayland-support-to-krita/18153>
    ];
  };
}
