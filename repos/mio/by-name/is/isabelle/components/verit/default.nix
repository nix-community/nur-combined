{
  fetchurl,
  pkgs,
  addSettings,
  lib,
}:

addSettings
  (pkgs.verit.overrideAttrs (_: {
    version = "2026.05";
    src = fetchurl {
      url = "https://www.verit-solver.org/download/2026.05/verit-2026.05.tar.gz";
      hash = "sha256-wNN1S1mdAsBENZBkDs770t31YDt63Nj737MbhOWcwvE=";
    };
  }))
  (finalAttrs: ''
    ISABELLE_VERIT=${lib.getExe' finalAttrs.finalPackage "veriT"}
  '')
