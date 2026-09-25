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
  version = "0-unstable-2026-09-23";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "NUR";
    rev = "a64d547e32ef81f6d6678acca0f3b317b24d11c1";
    hash = "sha256-F+PevD+e2NO2skg0q0sW5LKswjMT4btvNQ7lkyHtjkE=";
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
