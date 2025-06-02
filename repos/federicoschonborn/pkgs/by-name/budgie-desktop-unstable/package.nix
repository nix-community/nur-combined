{
  lib,
  budgie-desktop,
  gtk-layer-shell,
  libpeas2,
  nix-update-script,
  ...
}:

budgie-desktop.overrideAttrs (prevAttrs: {
  version = "10.9.2-unstable-2025-05-29";

  src = prevAttrs.src.override {
    rev = "a7e026e796966462b1eba86ae3953328703aee78";
    hash = "sha256-gSMtr1ejONWV+HnoDq0m424sZ3sooKFB0O8j/rVjAQA=";
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
