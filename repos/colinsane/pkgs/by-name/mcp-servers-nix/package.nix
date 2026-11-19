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
  version = "0-unstable-2026-11-18";
  src = fetchFromGitHub {
    owner = "natsukium";
    repo = "mcp-servers-nix";
    rev = "056517f2329b35db93b873b96f6c117d9fa2dce0";
    hash = "sha256-ewKedLQffh1/eDyMuoWaAqMvjRWetQo8Mc9RuQobuoU=";
  };
  flake = flake-inputs.import-flake {
    inherit src;
  };
  overlay = flake.overlays.default;
  packages =
    let
      self = pkgs.extend overlay;
    in
    overlay self pkgs;
in
src.overrideAttrs (base: {
  # attributes required by update scripts.
  # the main output of this derivation is `pkgs.mcp-servers-nix.flake.outputs`.
  inherit src version;
  pname = "mcp-servers-nix";

  passthru = base.passthru // {
    inherit flake overlay packages;
    updateScript = updater-tools.requireAll [
      (update-guard.days 2)
      (nix-update-script {
        extraArgs = [
          "--version"
          "branch"
        ];
      })
    ];
  };
})
