# TODO: serena: disable remote news fetch on launch (serena.dashboard:_fetch_news)
{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
  pkgs,
  update-guard,
  updater-tools,
}:
let
  version = "0-unstable-2026-08-27";
  src = fetchFromGitHub {
    owner = "natsukium";
    repo = "mcp-servers-nix";
    rev = "78afd1ae1599a95da8d8fa8133cefe8c9f12806c";
    hash = "sha256-pNnb33FyN1Uw2ahItIVZtFnpHxlvHRyRZRaavt5DzmM=";
  };
  flake = flake-inputs.import-flake {
    inherit src;
  };
  overlay = flake.overlays.default;
  packages = let
    self = pkgs.extend overlay;
  in
    overlay self pkgs;
in src.overrideAttrs (base: {
  # attributes required by update scripts.
  # the main output of this derivation is `pkgs.mcp-servers-nix.flake.outputs`.
  pname = "mcp-servers-nix";
  src = src;
  version = version;

  passthru = base.passthru // {
    inherit flake overlay packages;
    updateScript = updater-tools.requireAll [
      (update-guard.days 2)
      (nix-update-script {
        extraArgs = [ "--version" "branch" ];
      })
    ];
  };
})
