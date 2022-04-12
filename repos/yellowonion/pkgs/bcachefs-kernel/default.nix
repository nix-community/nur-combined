{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "de2fbf8b875fd8e61cc9a583d073f5527e3cb8e7";
  diffHash = "1cq5gxr6b5dwm3m784l2wj1z7g2ybwxnikwr65njsq2iljl3yh24";
  shorthash = lib.strings.substring 0 7 commit;
  kernelVersion = kernel.version;
  oldPatches = kernelPatches;
    in
(kernel.override (args // {
  argsOverride = {

  version = "${kernelVersion}-bcachefs-unstable-${shorthash}";
  extraMeta.branch = versions.majorMinor kernelVersion;

  } // (args.argsOverride or { });

  kernelPatches = [{
      name = "bcachefs-${commit}";
      patch = fetchurl {
        name = "bcachefs-${commit}.diff";
        url = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${commit}&id2=v${lib.versions.majorMinor kernelVersion}";
        sha256 = diffHash;
      };
      extraConfig = "BCACHEFS_FS m";
  }] ++ oldPatches;
}))
