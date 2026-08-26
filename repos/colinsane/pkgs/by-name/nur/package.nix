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
  version = "0-unstable-2026-08-25";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "NUR";
    rev = "999ef1aefd069b1eac5c56338f2cf3f1da89fab3";
    hash = "sha256-QTxosWA62d6JdYwtxBaGQd8HLoSKe564fLTy3Mx4f/E=";
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
