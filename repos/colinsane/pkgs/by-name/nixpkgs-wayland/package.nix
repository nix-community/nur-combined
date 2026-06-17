{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-06-15";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "a2d075c336f3e8fe9155f2c9b144ac880f8f97e2";
    hash = "sha256-7aAJlz2xwWLA4x5jO9h5fYCleJ5LygOz1AAMtp7g8bI=";
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
