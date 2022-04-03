{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "30129d957b577fc300b4e206870641093a96e20d";
  diffHash = "00zd2ldx5c2nxc6pnvzxz088n3gi899274hxksxyfs3hbv6cl0qc";
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
