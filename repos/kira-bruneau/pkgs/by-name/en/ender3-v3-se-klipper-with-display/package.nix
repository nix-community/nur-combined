{
  klipper,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

klipper.overrideAttrs (finalAttrs: {
  pname = "ender3-v3-se-klipper-with-display";
  version = "1.0.0-unstable-2025-08-04";

  src = fetchFromGitHub {
    owner = "jpcurti";
    repo = "ender3-v3-se-klipper-with-display";
    rev = "cecc1bba1d8469253600f0d6c383549a8ac9b0aa";
    hash = "sha256-B4vTNLptmxVxuQZvEk9O3eE9u7aETf0Nl8CAyZHiM1c=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = finalAttrs.meta // {
    description = "Fork of klipper with auto Z-offset calibration & display support for the Ender3 V3 SE";
  };
})
