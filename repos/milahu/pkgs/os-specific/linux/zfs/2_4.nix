{
  callPackage,
  lib,
  nixosTests,
  stdenv,
  fetchpatch,
  ...
}@args:

callPackage ./generic.nix args rec {
  # You have to ensure that in `pkgs/top-level/linux-kernels.nix`
  # this attribute is the correct one for this package.
  kernelModuleAttribute = "zfs_2_4";

  kernelMinSupportedMajorMinor = "4.18";
  kernelMaxSupportedMajorMinor = "7.1";

  # this package should point to the latest release.
  version = "2.4.3-pr-11082-2026-08-11";

  # https://github.com/openzfs/zfs/pull/11082
  # branch parent: 733f048fd6680f013691876e9f7ca23dc63ade52 2026-07-14
  rev = "c873ebf87865683b6685739e4fd9d4958f0aa8b4";

  hash = "sha256-+3b9CYXjo3HWNXFtcrrJlde4eug+IqcJ9QOVpcc8HSQ=";

  extraPatches = [
    # this has been merged into master on 2026-05-15
    /*
    # https://github.com/openzfs/zfs/issues/18366
    # dedup data corruption fix unreleased as of OpenZFS 2.4.3
    (fetchpatch {
      url = "https://github.com/openzfs/zfs/commit/6fb72fda0f60d9efb591e320f83f78b19ec451cc.patch?full_index=1";
      hash = "sha256-UuSVmO61Ux5S3F+JAtRnHyeVS4EFobDTKBuD5s8PI+k=";
    })
    */
  ];

  postPatch = ''
    sed -i -E 's/^(Version:      ) .*$/\1 ${version}/' META
  '';

  tests = {
    inherit (nixosTests.zfs) series_2_4;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isx86_64 {
    inherit (nixosTests.zfs) installer;
  };

  maintainers = with lib.maintainers; [
    adamcstephens
    amarshall
  ];
}
