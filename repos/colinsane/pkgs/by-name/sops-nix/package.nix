{
  fetchFromGitHub,
  nix-update-script,
  pkgs,
}:
let
  # nix-update-script insists on this weird `assets-` version format
  version = "assets-unstable-2025-12-07";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "aeb517262102f13683d7a191c7e496b34df8d24c";
    hash = "sha256-i9GMbBLkeZ7MVvy7+aAuErXkBkdRylHofrAjtpUPKt8=";
  };
  flake = import "${src}/flake.nix";
  evaluated = flake.outputs {
    self = evaluated;
    nixpkgs = pkgs;
  };
  overlay = evaluated.overlays.default;
  final = pkgs.extend overlay;
in src.overrideAttrs (base: {
  # attributes required by update scripts
  pname = "sops-nix";
  src = src;
  version = version;

  passthru = base.passthru
    // (overlay final pkgs)
    // { inherit (evaluated) nixosModules; }
    // {
      updateScript = nix-update-script {
        extraArgs = [ "--version" "branch" ];
      };
    }
  ;
})
