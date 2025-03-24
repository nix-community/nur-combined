{
  lib,
  fetchFromGitHub,
  nheko,
  lmdbxx,
  nix-update-script,
}:

nheko.overrideAttrs (prevAttrs: {
  version = "0.12.0-unstable-2025-03-22";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "b3026e297871666ad3b55d95af4be9f7f12a65ea";
    hash = "sha256-/t4SKOGld3pQw+QvMBCU3DooXijZt9IL2AhJvaLQ6lk=";
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
