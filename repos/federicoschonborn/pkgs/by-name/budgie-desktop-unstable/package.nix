{
  lib,
  budgie-desktop,
  gtk-layer-shell,
  nix-update-script,
  xfce,
  ...
}:

budgie-desktop.overrideAttrs (prevAttrs: {
  version = "10.9.2-unstable-2025-03-17";

  src = prevAttrs.src.override {
    rev = "369554d292e4d2f9141759e6f993604eb4e35ef4";
    hash = "sha256-GWxvnZNiK5kTX1GZrCpb8Pb4h0csahxVB8SeK9gRHGU=";
  };

  patches = [ ];

  buildInputs = (prevAttrs.buildInputs or [ ]) ++ [
    gtk-layer-shell
  ];

  mesonFlags = (prevAttrs.mesonFlags or [ ]) ++ [
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
