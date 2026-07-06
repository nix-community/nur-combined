{
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
}:
let
  version = "assets-unstable-2026-07-04";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "sops-nix";
    rev = "f1406619a3884cd5c47992a70b8b35c9c0fcb4c9";
    hash = "sha256-aCWC8ngycU7OdJrU2+Je3qf+1a2ykuBvpPhZT/9tXMc=";
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
