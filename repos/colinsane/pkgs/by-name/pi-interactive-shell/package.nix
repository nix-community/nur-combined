{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-interactive-shell";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-interactive-shell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gpiF+9+4TbV4ts/BBnQzCUvPE4OjiTdTUqAywHn3+RM=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-OLRYZkpg7Wfpc1xhsWhj4JNm/xbmOTy9r4Xk8Z9Fhtw=";

  dontNpmBuild = true; # package.json defines no build script
  dontNpmPrune = true; # npm prune fails on this package's lockfile layout

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pi extension for running AI coding agents in TUI overlays with interactive, hands-free, and dispatch supervision";
    homepage = "https://github.com/nicobailon/pi-interactive-shell";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [
      # see: $out/node_modules/zigpty/prebuilds/
      binaryNativeCode
    ];
  };
})
