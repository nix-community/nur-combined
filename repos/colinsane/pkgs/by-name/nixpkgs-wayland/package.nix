{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-09-28";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "a36f829f2bbc54ecc827fe9555985b4124a5d6c4";
    hash = "sha256-RJ6h6rgOZ5CeYHJX/yA+1fwZSBQ67fsdBtoC+fl9GXI=";
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
