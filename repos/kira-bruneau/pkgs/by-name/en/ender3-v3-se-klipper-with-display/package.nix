{
  klipper,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

klipper.overrideAttrs (attrs: {
  pname = "ender3-v3-se-klipper-with-display";
  version = "1.0.0-unstable-2026-07-29";

  src = fetchFromGitHub {
    owner = "jpcurti";
    repo = "ender3-v3-se-klipper-with-display";
    rev = "d74d36bb69bd8c561a169fd99e8c83e254318562";
    hash = "sha256-CTxXSS9JwVEzTZ+e6el0y0T4UGjae9Jb62UVNbhkLgo=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  installPhase =
    builtins.replaceStrings [ "cp $src/lib/katapult/flashtool.py $out/lib/scripts/flash_can.py" ] [ "" ]
      attrs.installPhase;

  meta = attrs.meta // {
    description = "Fork of klipper with auto Z-offset calibration & display support for the Ender3 V3 SE";
  };
})
