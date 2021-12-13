{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "6bb1ba5c94c225a95cb59cb9670b558bcb1b4f81";
  diffHash = "1jwhx71xqrdm6bgg41s68cl0zdmwbp67j3bfhsj888q3pb4jpbha";
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
