{ lib, buildPackages, fetchurl, perl, buildLinux, fetchpatch, kernelPatches, ...} @ args:

with lib;

let
  commit = "043cfba30c743a6faa4e53c5a88a259f8726ac01";
  diffHash = "0s1n84v7w62bkgjhhs81qzsbl74362adqjdcv787m1s3dlg3xl04";
  shorthash = lib.strings.substring 0 7 commit;
  kernelVersion = "5.13.19";
  oldPatches = kernelPatches;
    in
buildLinux (args // rec {
  version = "${kernelVersion}-bcachefs-unstable-${shorthash}";

  modDirVersion = "5.13.19";
  extraMeta.branch = versions.majorMinor kernelVersion;

    src = fetchurl {
      url = "mirror://kernel/linux/kernel/v5.x/linux-${kernelVersion}.tar.xz";
      sha256 = "0yxbcd1k4l4cmdn0hzcck4s0yvhvq9fpwp120dv9cz4i9rrfqxz8";
    };
    kernelPatches = let patch = {
      name = "bcachefs-${commit}";
      patch = fetchpatch {
        name = "bcachefs-${commit}.diff";
        url = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${commit}&id2=v${lib.versions.majorMinor kernelVersion}";
        sha256 = diffHash;
      };
      extraConfig = "BCACHEFS_FS m";
        # fix util pull/124486 is merged
    }; in [patch] ++ lib.remove patch oldPatches;
} // (args.argsOverride or {  }))
