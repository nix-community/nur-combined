{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2026-06-30";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "c28e5e9b8a1aaa91207c5689e72029911326e46c";
    hash = "sha256-iTAAdz9JTQ8/yUPBK5/HgwcUp+rkkgAFJumY2i3bLyc=";
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
