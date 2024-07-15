{ pkgs
, fetchFromGitHub
, nix-update-script
}:
let
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "0703ba03fd9c1665f8ab68cc3487302475164617";
    hash = "sha256-eTpnrT6yu1vp8C0B5fxHXhgKxHoYMoYTEikQx///jxY=";
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
  version = "assets-unstable-2024-07-14";
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
