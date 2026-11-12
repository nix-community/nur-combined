{
  applyPatches,
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
}:
let
  version = "assets-unstable-2026-11-02";
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "Mic92";
      repo = "sops-nix";
      rev = "b18e01ce148eb3efff5de2f2d3181ca53b2b2a54";
      hash = "sha256-Y/JIHTnMlOabDfyaSBubWGLDIVGihLEUuoMhFvQKaDo=";
    };
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
  postPatch = null;
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
