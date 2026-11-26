{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  aws-lc,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mnamer-rs";
  version = "3.0.0-dev9";

  src = fetchCrate {
    pname = "mnamer";
    inherit (finalAttrs) version;
    hash = "sha256-6FLh02YHoZ9CgMe/RRz5GIk53efogbp1GlnCWHsBzv0=";
  };

  cargoLock.lockFile = ./Cargo.lock;
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    aws-lc
  ];

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
