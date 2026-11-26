{
  klipper,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

klipper.overrideAttrs (attrs: {
  pname = "ender3-v3-se-klipper-with-display";
  version = "1.0.1-unstable-2026-11-26";

  src = fetchFromGitHub {
    owner = "jpcurti";
    repo = "ender3-v3-se-klipper-with-display";
    rev = "0f707cd667de813b0ed64acd6d89ae5a4528f155";
    hash = "sha256-RF/tbyWy4CAvOj/8jwK35m1XBarPGn4eTwZMs20NRxs=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  installPhase =
    builtins.replaceStrings [ "cp $src/lib/katapult/flashtool.py $out/lib/scripts/flash_can.py" ] [ "" ]
      attrs.installPhase;

  meta = attrs.meta // {
    description = "Fork of klipper with auto Z-offset calibration & display support for the Ender3 V3 SE";
  };
})
