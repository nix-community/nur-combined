{
  lib,
  budgie-desktop,
  gtk-layer-shell,
  nix-update-script,
  xfce,
  ...
}:

budgie-desktop.overrideAttrs (prevAttrs: {
  version = "10.9.2-unstable-2025-04-02";

  src = prevAttrs.src.override {
    rev = "ce1c4d1295405a6eb1b54d23e14e042585f142b1";
    hash = "sha256-yraO3rQDfBvzoDBTpInMMKWocPNGjLeu/SmC4D3AwOs=";
  };

  patches = [ ];

  buildInputs = (prevAttrs.buildInputs or [ ]) ++ [
    gtk-layer-shell
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

  meta = (prevAttrs.meta or { }) // {
    broken = lib.versionOlder xfce.libxfce4windowing.version "4.19.7";
  };
})
