{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-vim";
  version = "0.1.4-unstable-2026-07-08";

  src = fetchFromGitHub {
    owner = "leohenon";
    repo = "pi-vim";
    rev = "819a8b0f0a1ec2171dffd9528636dcae7ce35e70";
    hash = "sha256-Jt5cRO/jVJepj58GOD3zpX/GILezS8jLnImiszOeA8s=";
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-MRpYRkvlRylEffz3fSSKROSNnxFniiO7YoYTGUc3c/Q=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Vim mode for pi with motions, text objects, and visual mode.";
    homepage = "https://github.com/leohenon/pi-vim";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
