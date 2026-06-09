{
  callPackage,
  fetchFromGitHub,
  nix-update-script,
  nixpkgs-bootstrap,
  stdenv,
}:
let
  # TODO: this should actually just be nur's `nixpkgs` flake lock.
  # i want to match it as closely as possible, so i can stop dealing with broken updates.
  pkgs = nixpkgs-bootstrap.master.unpatchedNixpkgs;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nur";
  version = "0-unstable-2026-06-09";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "NUR";
    rev = "1c22b665d0508fa31ebeba80e50fd7b673dd123a";
    hash = "sha256-r4szdHt7TyTagmHTI7g3l/4NKmZijOZ2oyevvRx2wPA=";
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
    updateScript = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
  };

  meta = {
    documentation = "https://nur.nix-community.org/documentation";
    homepage = "https://github.com/nix-community/NUR";
  };
})
