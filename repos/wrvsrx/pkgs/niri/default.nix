{ niri, fetchpatch }:
niri.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/niri/compare/tag_no-import-environment_1%5E...tag_no-import-environment_1.patch";
      hash = "sha256-8PHqgjc1Iva/8i2E0sNAFU5VMV+2inAphy1cRV5mYGs=";
    })
  ];
})
