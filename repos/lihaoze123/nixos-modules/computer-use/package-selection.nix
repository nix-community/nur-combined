{ cfg
, flakePackages
, lib
,
}:
let
  linuxFeatures = import ../../pkgs/codex-desktop/features.nix { inherit lib; };
  requestedFeatureIds = cfg.linuxFeatures ++ lib.optional cfg.remoteMobileControl.enable "remote-mobile-control";
  normalizedFeatureIds = linuxFeatures.normalize requestedFeatureIds;
in
{
  inherit normalizedFeatureIds;

  package =
    if cfg.package != null then
      cfg.package
    else
      flakePackages.codex-desktop.override {
        enableComputerUseUi = cfg.computerUseUi.enable;
        linuxFeatureIds = normalizedFeatureIds;
      };
}
