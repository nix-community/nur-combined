{ lib, fetchurl, kernel, kernelPatches, version, ...} @ args:

with lib;

let
  commit = "62cffccd9dc463dc0dd19439f9f89cb477ddb181";
  diffHash = "1q6ziraayn15c1li5rqssnhqjdyfvwyzy5kb44pm94jzdhbl7lja";
  shorthash = lib.strings.substring 0 7 commit;
  kernelVersion = kernel.version;
  oldPatches = kernelPatches;
    in
(kernel.override (args // {
  argsOverride = {

    version = "${kernelVersion}-bcachefs-${version}-${shorthash}";
  extraMeta.branch = versions.majorMinor kernelVersion;

  } // (args.argsOverride or { });

  kernelPatches = [{
      name = "bcachefs-${commit}";
      patch = fetchurl {
        name = "bcachefs-${commit}.diff";
        url = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${commit}&id2=v${lib.versions.majorMinor kernelVersion}";
        sha256 = diffHash;
      };
      extraConfig = ''
        CRYPTO_CRC32C_INTEL y
        BCACHEFS_FS y
        BCACHEFS_POSIX_ACL y
        BCACHEFS_QUOTA y
      '';
  }] ++ oldPatches;
}))
