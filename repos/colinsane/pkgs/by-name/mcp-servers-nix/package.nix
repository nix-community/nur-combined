# TODO: serena: disable remote news fetch on launch (serena.dashboard:_fetch_news)
{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-06-30";
  src = fetchFromGitHub {
    owner = "natsukium";
    repo = "mcp-servers-nix";
    rev = "e2e5ce54691fc6c851e7365da0cd67ad88962c4c";
    hash = "sha256-jZ+N/sWZV7jbOQVDN8ZBqaQFe94CrUrhIIibvmFc9tM=";
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
