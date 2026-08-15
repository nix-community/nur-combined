{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
}:
let
  version = "assets-unstable-2026-08-10";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "d1337e05ba0a8e88a75d2c0e1595d82f3b3e2ac4";
    hash = "sha256-G7qDAT98nywA4EFmJCwIRO5wKvDlBBN3BWpsOnjAto8=";
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
