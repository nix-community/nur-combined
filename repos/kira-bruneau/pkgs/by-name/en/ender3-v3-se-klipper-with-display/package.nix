{
  klipper,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

klipper.overrideAttrs (finalAttrs: {
  pname = "ender3-v3-se-klipper-with-display";
  version = "1.0.0-unstable-2025-03-17";

  src = fetchFromGitHub {
    owner = "jpcurti";
    repo = "ender3-v3-se-klipper-with-display";
    rev = "59eebbfcd66d3423e8345b3421f35b9aec8c18a2";
    hash = "sha256-KlvxfKPCX86s7/DIW1WZZynsKpptBi4dnwY0WcslXgg=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = finalAttrs.meta // {
    description = "Fork of klipper with auto Z-offset calibration & display support for the Ender3 V3 SE";
  };
})
