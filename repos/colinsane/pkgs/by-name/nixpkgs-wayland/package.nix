{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-11-18";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "58d6552ef346994998a1c7f0e40e366c874ef11b";
    hash = "sha256-BKm9QdiGgme0AP9idRCjmMubiQdZTKHunztsD6igomo=";
  };
  overlay = import "${src}/overlay.nix";

  final = pkgs.extend overlay;
in
src.overrideAttrs (base: {
  # attributes required by update scripts
  inherit src version;
  pname = "nixpkgs-wayland";

  # passthru only nixpkgs-wayland's own packages -- not the whole nixpkgs-with-nixpkgs-wayland-as-overlay:
  passthru = base.passthru // {
    inherit overlay;
    pkgs = overlay final pkgs;
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };
})
