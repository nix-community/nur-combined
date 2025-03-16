{
  lib,
  fetchFromGitHub,
  nheko,
  lmdbxx,
  nix-update-script,
}:

nheko.overrideAttrs (prevAttrs: {
  version = "0.12.0-unstable-2025-03-14";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "74f5386b29e5332efaf04c0a89bd6585acfe3de8";
    hash = "sha256-GVA5+RD+AVmO5U3EhxUUKUvJZ6XRqCnK8Moeml60UGo=";
  };

  # Remove lmdbxx
  nativeBuildInputs = builtins.filter (p: lib.getName p != "lmdbxx") (
    prevAttrs.nativeBuildInputs or [ ]
  );

  buildInputs = (prevAttrs.buildInputs or [ ]) ++ [
    lmdbxx
  ];

  strictDeps = true;

  passthru = (prevAttrs.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };
})
