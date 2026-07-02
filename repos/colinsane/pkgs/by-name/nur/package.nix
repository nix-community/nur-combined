{
  callPackage,
  fetchFromGitHub,
  nix-update-script,
  nixpkgs-bootstrap,
  stdenv,
  update-guard,
  updater-tools,
}:
let
  # TODO: this should actually just be nur's `nixpkgs` flake lock.
  # i want to match it as closely as possible, so i can stop dealing with broken updates.
  pkgs = nixpkgs-bootstrap.master.unpatchedNixpkgs;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nur";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "NUR";
    rev = "be450e66f52aa5c4aca2174798d8669087f5c1d0";
    hash = "sha256-APz/XeSnHC7wIvfdu13FWkGXkQ4eFE+Z057TONdDPL0=";
  };

  passthru = let
    nurOutputs = import finalAttrs.src {
      nurpkgs = pkgs;
      pkgs = pkgs;
    };
  in nurOutputs // {
    unlocked = callPackage ./unlocked.nix {
      nur = finalAttrs.finalPackage;
    };
    updateScript = updater-tools.requireAll [
      update-guard.weekly
      (nix-update-script {
        extraArgs = [ "--version" "branch" ];
      })
    ];
  };

  meta = {
    documentation = "https://nur.nix-community.org/documentation";
    homepage = "https://github.com/nix-community/NUR";
  };
})
