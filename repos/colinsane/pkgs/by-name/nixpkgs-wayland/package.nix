{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-11-21";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "9a785961f01e60267e15c7f22585057ed7f2c1b7";
    hash = "sha256-U6sVvWFWCocZr92DHYFUE71Z+pdp0EdaVFkyHtMPsio=";
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
