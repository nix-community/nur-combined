{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "17d44ed5e9b8e7b2a6dfe0cfe567302a02ced819";
  diffHash = "1w0yx7ywbdwzakr5gwjk2h2zv6qgh8dkjf5g8rapcvm1vqk92jlw";
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
