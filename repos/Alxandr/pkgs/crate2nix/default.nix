{
  pkgs,
  nurLib,
  nixVersions,
  fetchFromGitHub,
  crate2nix-package-update-script,
}:

let
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "crate2nix";
    rev = "5e1ecfd2d15b34ec90c2e51fdffbe8116595a767";
    hash = "sha256-2577vxyoBa8+ZRiXr3CuPtOuEtPRYsFPSZuEc/KI/80=";
  };

in
nurLib.crate2nix {
  inherit src;
  pname = "crate2nix";
  resolvedJson = ./Cargo.json;
  buildRustCrateForPkgs = pkgs: pkgs.buildRustCrate;

  updateScriptExtraArgs = [
    "--version"
    "branch"
  ];

  meta = {
    description = "A tool to generate Nix expressions for Rust crates";
    mainProgram = "crate2nix";
    homepage = "https://github.com/nix-community/crate2nix";
    license = [
      pkgs.lib.licenses.mit
      pkgs.lib.licenses.asl20
    ];
  };
}
