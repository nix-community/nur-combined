{
  klipper,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

klipper.overrideAttrs (finalAttrs: {
  pname = "ender3-v3-se-klipper-with-display";
  version = "1.0.0-unstable-2025-03-25";

  src = fetchFromGitHub {
    owner = "jpcurti";
    repo = "ender3-v3-se-klipper-with-display";
    rev = "373294837c95bf4e3d344979e60246e7ba8a5d9a";
    hash = "sha256-+sDsGGnZ7oP5Fb441mCf8jNh+VERMLKPCTyFGxXcUQY=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = finalAttrs.meta // {
    description = "Fork of klipper with auto Z-offset calibration & display support for the Ender3 V3 SE";
  };
})
