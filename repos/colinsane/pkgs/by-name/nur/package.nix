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
  version = "0-unstable-2026-09-09";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "NUR";
    rev = "e535158b12037c2671524aa69723d8707641c462";
    hash = "sha256-nb8H0gnLaAI64j5tihC03gwTJ71O3pBtYrXWKdAfMSM=";
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
