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
    rev = "205c8ba65a7f956d7837a710794001b3515c65ff";
    hash = "sha256-F+MFs5cJbqcrlu/6BzQhNwF7Ih26yG9Yg9p4xyDz5eY=";
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
