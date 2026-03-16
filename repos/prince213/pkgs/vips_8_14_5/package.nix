{
  lib,
  libgsf,
  orc,
  vips,
}:

let
  # meson.build:1:0: ERROR: Option "introspection" value enabled is not boolean (true or false).
  lib' = lib // {
    mesonEnable =
      feature: (if feature == "introspection" then lib.mesonBool else lib.mesonEnable) feature;
  };
in

(vips.override { lib = lib'; }).overrideAttrs (previousAttrs: {
  version = "8.14.5";
  src = previousAttrs.src.override {
    hash = "sha256-fG3DTP+3pO7sbqR/H9egJHU3cLKPU4Jad6qxcQ9evNw=";
  };
  patches = (previousAttrs.patches or [ ]) ++ [
    ./libjxl.patch
  ];
  buildInputs = (previousAttrs.buildInputs or [ ]) ++ [
    libgsf
    orc
  ];
})
