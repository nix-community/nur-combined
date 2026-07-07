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
  version = "0-unstable-2026-07-07";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "NUR";
    rev = "5967cd50a1241df50ebedd6f967b7456de6b63c5";
    hash = "sha256-fmSsLi7fm5+gMQp1uJ1h7As6F/5cIgFjm6l8bG/zOlg=";
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
