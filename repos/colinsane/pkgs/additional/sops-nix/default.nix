{ pkgs
, fetchFromGitHub
, nix-update-script
}:
let
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "909e8cfb60d83321d85c8d17209d733658a21c95";
    hash = "sha256-AsvPw7T0tBLb53xZGcUC3YPqlIpdxoSx56u8vPCr6gU=";
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
  version = "assets-unstable-2024-07-21";
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
