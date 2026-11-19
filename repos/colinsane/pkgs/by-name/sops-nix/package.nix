{
  applyPatches,
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
}:
let
  version = "assets-unstable-2026-11-16";
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "Mic92";
      repo = "sops-nix";
      rev = "7c637afdccdf9bcf35c4a2d67b58a77c1fd843a4";
      hash = "sha256-Y/JIHTnMlOabDfyaSBubWGLDIVGihLEUuoMhFvQKaDo=";
    };
  };
  flake = flake-inputs.import-flake {
    inherit src;
    # overrides.nixpkgs = ??
  };
in
src.overrideAttrs (base: {
  # attributes required by update scripts.
  # the main output of this derivation is `pkgs.sops-nix.nixosModules.sops`.
  inherit src version;
  pname = "sops-nix";
  postPatch = null;

  passthru = base.passthru // {
    inherit flake;
    # inherit (flake) nixosModules overlays;
    # modules/sops is free-standing.
    # prefer to `import sops-nix.nixosModules.sops` directly,
    # and avoid the whole flake wrangling.
    nixosModules.sops = "${src}/modules/sops";
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };
})
