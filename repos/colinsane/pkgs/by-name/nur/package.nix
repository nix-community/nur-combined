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
  version = "0-unstable-2026-11-13";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "NUR";
    rev = "47a60ac60fb1654f40ca62bda052c90e95610834";
    hash = "sha256-859Epq6BKEzaC8nI3KbMwLFdSkh2AUXGOB3jALwIRPg=";
  };

  passthru =
    let
      nurOutputs = import finalAttrs.src {
        inherit pkgs;
        nurpkgs = pkgs;
      };
    in
    nurOutputs
    // {
      unlocked = callPackage ./unlocked.nix {
        nur = finalAttrs.finalPackage;
      };
      updateScript = updater-tools.requireAll [
        update-guard.weekly
        (nix-update-script {
          extraArgs = [
            "--version"
            "branch"
          ];
        })
      ];
    };

  meta = {
    documentation = "https://nur.nix-community.org/documentation";
    homepage = "https://github.com/nix-community/NUR";
  };
})
