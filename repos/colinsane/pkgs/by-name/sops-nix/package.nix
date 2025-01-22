{ pkgs
, fetchFromGitHub
, nix-update-script
}:
let
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "015d461c16678fc02a2f405eb453abb509d4e1d4";
    hash = "sha256-j9IdflJwRtqo9WpM0OfAZml47eBblUHGNQTe62OUqTw=";
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
  version = "assets-unstable-2025-01-20";
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
