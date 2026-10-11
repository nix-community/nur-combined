{
  lib,
  rustPlatform,
  fetchCrate,
  nix-update-script,
  callPackage,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mnamer-rs";
  version = "3.0.0-dev5";

  src = fetchCrate {
    pname = "mnamer";
    inherit (finalAttrs) version;
    hash = "sha256-3l70YFbFxKKKUvnBo2d3i/+oAjQ3r+VAEnAeO3KrJSU=";
  };

  cargoLock.lockFile = ./Cargo.lock;
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  doCheck = false;

  passthru = {
    updateScript = nix-update-script {
      attrPath = "mnamer-rs";
      extraArgs = [
        "-f"
        "."
        "--version=unstable"
        "--version-regex=^(3[.]0[.]0-dev[0-9]+)$"
        "--generate-lockfile"
      ];
    };
    tests.packaging = callPackage ../../tests/pkgs/mnamer-rs.nix {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Rename and organize media files using online metadata";
    homepage = "https://github.com/jkwill87/mnamer";
    license = lib.licenses.mit;
    mainProgram = "mnamer";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
