{
  klipper,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

klipper.overrideAttrs (finalAttrs: {
  pname = "ender3-v3-se-klipper-with-display";
  version = "1.0.0-unstable-2025-12-17";

  src = fetchFromGitHub {
    owner = "jpcurti";
    repo = "ender3-v3-se-klipper-with-display";
    rev = "88d81b5a602dad88cdb29734046232662d5fed72";
    hash = "sha256-ewj4XZODr5FVj/KjQKj8FshUPNPsoTnPt7d4nGXxyTg=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = finalAttrs.meta // {
    description = "Fork of klipper with auto Z-offset calibration & display support for the Ender3 V3 SE";
  };
})
