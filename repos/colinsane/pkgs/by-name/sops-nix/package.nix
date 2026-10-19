{
  applyPatches,
  fetchFromGitHub,
  flake-inputs,
  nix-update-script,
}:
let
  version = "assets-unstable-2026-10-15";
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "Mic92";
      repo = "sops-nix";
      rev = "44931708c62937c2b1bf7953902989fa5bb9ee1b";
      hash = "sha256-4GuMPW90JSxXWDPUB9M+1m7fYbe3H0apOd86/zBQ2Kw=";
    };
    # XXX(2026-09-16): nixpkgs dropped buildGo125Module; package builds fine with 1.26 instead.
    postPatch = ''
      substituteInPlace pkgs/sops-install-secrets/default.nix \
        --replace-fail buildGo125Module buildGo126Module
    '';
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
