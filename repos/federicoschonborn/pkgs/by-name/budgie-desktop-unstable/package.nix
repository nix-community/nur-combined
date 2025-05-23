{
  lib,
  budgie-desktop,
  gtk-layer-shell,
  libpeas2,
  nix-update-script,
  ...
}:

budgie-desktop.overrideAttrs (prevAttrs: {
  version = "10.9.2-unstable-2025-05-13";

  src = prevAttrs.src.override {
    rev = "f0d30bc83f1a498f769bd09e08210ba04e45a419";
    hash = "sha256-jjhbg1nN1Fte7KtTdTh5bVMuU320+n7iZmkUaZWepeU=";
  };

  patches = [ ];

  buildInputs = (prevAttrs.buildInputs or [ ]) ++ [
    gtk-layer-shell
    libpeas2
  ];

  mesonFlags = (prevAttrs.mesonFlags or [ ]) ++ [
    # Don't check for runtime dependencies to avoid bloating up the derivation.
    (lib.mesonBool "with-runtime-dependencies" false)
  ];

  passthru = (prevAttrs.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };
})
