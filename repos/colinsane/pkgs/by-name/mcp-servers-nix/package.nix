# TODO: serena: disable remote news fetch on launch (serena.dashboard:_fetch_news)
{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-07-05";
  src = fetchFromGitHub {
    owner = "natsukium";
    repo = "mcp-servers-nix";
    rev = "14686054fc50e5a806ca0bde41733179ba2d5244";
    hash = "sha256-ynyinghI6g9YDpNdee7QdP9lGT47vOTXNCRVAP8p+Zw=";
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
    updateScript = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
  };
})
