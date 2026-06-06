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
  version = "0-unstable-2026-06-06";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "NUR";
    rev = "cb5ab707948fb679ce52f7f03c857912e847d763";
    hash = "sha256-JpRPPggHTg9qqs4Ir4Yqd+bGw09rpY/nlKDQbb/9Kvw=";
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
