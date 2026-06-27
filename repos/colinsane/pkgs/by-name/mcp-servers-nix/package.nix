# TODO: serena: disable remote news fetch on launch (serena.dashboard:_fetch_news)
{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-06-23";
  src = fetchFromGitHub {
    owner = "natsukium";
    repo = "mcp-servers-nix";
    rev = "f4524b1ab386b574f557db05cb02bee02c4497a2";
    hash = "sha256-GmD3s4qEEslKqUNK+2gFFPHMzsmJUTi1j+9KirbkUto=";
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
