{ pkgs
, fetchFromGitHub
, nix-update-script
}:
let
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "bcb8b65aa596866eb7e5c3e1a6cccbf5d1560b27";
    hash = "sha256-ZjUjbvS06jf4fElOF4ve8EHjbpbRVHHypStoY8HGzk8=";
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
  # nix-update-script insists on this weird `assets-` version format
  version = "assets-unstable-2024-12-29";
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
