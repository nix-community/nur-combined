{ config, lib, sane-lib, ... }:
let
  inherit (lib) mkIf;
in {
  sane.programs.zeal-qt5 = {
    persist.plaintext = [
      ".cache/Zeal"
      ".local/share/Zeal"
    ];
    fs.".local/share/Zeal/Zeal/system" = sane-lib.fs.wantedSymlinkTo "/run/current-system/sw/share/docset";
  };

  environment.pathsToLink = mkIf config.sane.programs.zeal-qt5.enabled [
    "/share/docset"
  ];
}
