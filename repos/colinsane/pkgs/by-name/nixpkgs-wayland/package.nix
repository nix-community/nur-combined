{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-07-28";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "3a4a2ab8c442c827adfea29347d9032e9e19163f";
    hash = "sha256-B0YVINZXvGD2Ivj2VZdF+TJou9V2LSDI8Pj9/Kw3CaQ=";
  };
  overlay = import "${src}/overlay.nix";

  final = pkgs.extend overlay;
in src.overrideAttrs (base: {
  # attributes required by update scripts
  pname = "nixpkgs-wayland";
  src = src;
  version = version;

  # passthru only nixpkgs-wayland's own packages -- not the whole nixpkgs-with-nixpkgs-wayland-as-overlay:
  passthru = base.passthru // {
    inherit overlay;
    pkgs = overlay final pkgs;
    updateScript = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
  };
})
