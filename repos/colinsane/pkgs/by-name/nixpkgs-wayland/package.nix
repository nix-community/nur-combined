{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-11-20";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "b3f05902daa29ec3465b4c4d5bef3e8bc3e29f71";
    hash = "sha256-JFiK7RyE4MAbtRBrH8d2fV+RRpIzwCF0JsXCZAjYwOk=";
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
