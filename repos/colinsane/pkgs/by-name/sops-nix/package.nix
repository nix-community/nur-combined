{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
}:
let
  version = "assets-unstable-2026-06-20";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "420f8d2e9882911f65cfac15cc706f639ba96cca";
    hash = "sha256-NFHmA7H47adqiyp+0iEOyZOQhmigDqA/NBAlf4imB6U=";
  };
  flake = flake-inputs.import-flake {
    inherit src;
    # overrides.nixpkgs = ??
  };
in src.overrideAttrs (base: {
  # attributes required by update scripts.
  # the main output of this derivation is `pkgs.sops-nix.nixosModules.sops`.
  pname = "sops-nix";
  src = src;
  version = version;

  passthru = base.passthru // {
    # modules/sops is free-standing.
    # prefer to `import sops-nix.nixosModules.sops` directly,
    # and avoid the whole flake wrangling.
    nixosModules.sops = "${src}/modules/sops";
    # inherit (flake) nixosModules overlays;
    inherit flake;
    updateScript = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
  };
})
