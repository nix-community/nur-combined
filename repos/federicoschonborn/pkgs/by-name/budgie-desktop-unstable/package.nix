{
  lib,
  budgie-desktop,
  gtk-layer-shell,
  libpeas2,
  nix-update-script,
  ...
}:

budgie-desktop.overrideAttrs (prevAttrs: {
  version = "10.9.2-unstable-2025-05-24";

  src = prevAttrs.src.override {
    rev = "d460e19374cbfc6ffefb95343f4e7c31c7371699";
    hash = "sha256-ZEJUAQpIAL1FaYkPIxKEoPPHmdduoYH8Ju8z7KP6I/E=";
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
