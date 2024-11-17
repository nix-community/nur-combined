{ pkgs
, fetchFromGitHub
, nix-update-script
}:
let
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "4c91d52db103e757fc25b58998b0576ae702d659";
    hash = "sha256-HC0anOL+KmUQ2hdRl0AtunbAckasxrkn4VLmxbW/WaA=";
  };
  flake = import "${src}/flake.nix";
  evaluated = flake.outputs {
    self = evaluated;
    nixpkgs = pkgs;
    nixpkgs-stable = pkgs;  #< shameless lie :)
  };
  overlay = evaluated.overlays.default;
  final = pkgs.extend overlay;
in src.overrideAttrs (base: {
  # attributes required by update scripts
  pname = "sops-nix";
  # nix-update-script insists on this weird `assets-` version format
  version = "assets-unstable-2024-11-11";
  src = src;

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
