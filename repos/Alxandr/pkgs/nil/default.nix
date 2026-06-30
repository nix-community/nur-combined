{
  pkgs,
  nurLib,
  nixVersions,
  fetchFromGitHub,
  crate2nix-package-update-script,
}:

let
  src = fetchFromGitHub {
    owner = "oxalica";
    repo = "nil";
    rev = "504599f7e555a249d6754698473124018b80d121";
    hash = "sha256-18j8X2Nbe0Wg1+7YrWRlYzmjZ5Wq0NCVwJHJlBIw/dc=";
  };

  customBuildRustCrateForPkgs =
    pkgs:
    pkgs.buildRustCrate.override {
      defaultCrateOverrides = pkgs.defaultCrateOverrides // {
        builtin = prev: {
          nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [
            (nixVersions.latest or nixVersions.unstable)
          ];
        };
      };
    };

in
nurLib.crate2nix {
  inherit src;
  pname = "nil";
  resolvedJson = ./Cargo.json;
  buildRustCrateForPkgs = customBuildRustCrateForPkgs;

  updateScriptExtraArgs = [
    "--version"
    "branch"
  ];

  meta = {
    description = "NIx Language server, an incremental analysis assistant for writing in Nix.";
    mainProgram = "nil";
    homepage = "https://github.com/oxalica/nil";
    license = [
      pkgs.lib.licenses.mit
      pkgs.lib.licenses.asl20
    ];
  };
}
