{
  lib,
  fetchFromGitHub,
  nheko,
  lmdbxx,
  nix-update-script,
}:

nheko.overrideAttrs (prevAttrs: {
  version = "0.12.0-unstable-2025-03-20";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "f462eb84dcd57764d0f639e3da6890b0ce67b373";
    hash = "sha256-vkmii74GApaqsxz8Yfr9iefBOY3cxuKLC57wvCh8R1o=";
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
