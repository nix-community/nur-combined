{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "f9d2e809a8c3b3a3c6bb0f8fe8e646425f7fce8d";
  diffHash = "0na7x4vz3c8zimdk9nl7a38jym748kk3lrdj7lj8vjwq8a6yrmcp";
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
