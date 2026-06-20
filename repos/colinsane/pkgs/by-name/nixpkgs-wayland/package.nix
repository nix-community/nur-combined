{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-06-20";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "b37f4ba442662f6de3692d7056d1016ac6b3af81";
    hash = "sha256-kozdj7R5A3uoFmf8XJOZip9hvzjr7cOxf0zYrjU6rA0=";
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
