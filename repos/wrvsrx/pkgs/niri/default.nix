{
  niri,
  fetchpatch,
}:
niri.overrideAttrs (
  finalAttrs: oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://github.com/wrvsrx/niri/compare/tag_no-import-environment_1%5E..tag_no-import-environment_1.patch";
        hash = "sha256-8PHqgjc1Iva/8i2E0sNAFU5VMV+2inAphy1cRV5mYGs=";
      })
      (fetchpatch {
        url = "https://github.com/wrvsrx/niri/compare/tag_support-shm-sharing_1~18..tag_support-shm-sharing_1.patch";
        hash = "sha256-dbxN3aZ2fyokQ5L2v4CO8nt+RbVAY0CArzRMwpybvhk=";
      })
    ];
  }
)
