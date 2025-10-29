{
  sources,
  lib,
  callPackage,
  ...
}@importArgs:
args:
let
  helpers = callPackage ../../helpers/kernel { };
  inherit (helpers) mkKernel readStructuredConfig;

  splitted = lib.splitString "-" args.version;
  ver0 = builtins.elemAt splitted 0;
  major = lib.versions.pad 2 ver0;

  cachyosConfigFile = sources.cachyos-kernel.src + "/${args.configVariant}/config";
  cachyosConfig = readStructuredConfig cachyosConfigFile;
  customConfig = import (../../helpers/kernel/custom-config + "/${major}.nix") importArgs;

  kernelPackage = mkKernel (
    lib.recursiveUpdate args rec {
      pname = "linux-cachyos-${args.pname}";

      structuredExtraConfig =
        cachyosConfig
        // customConfig
        // {
          LOCALVERSION = lib.kernel.freeform "-lantian-cachy";
        };

      modDirSuffix = "-lantian-cachy";

      extraPatches = [
        {
          name = "0001-cachyos-base-all.patch";
          patch = sources.cachyos-kernel-patches.src + "/${major}/all/0001-cachyos-base-all.patch";
        }
      ];

      extraArgs = lib.recursiveUpdate {
        ignoreConfigErrors = true;

        passthru = {
          inherit structuredExtraConfig;
        };

        extraMeta = {
          description =
            "Linux CachyOS Kernel with Lan Tian Modifications"
            + lib.optionalString (args.lto or false) " and Clang+ThinLTO";
        };
      } (args.extraArgs or { });
    }
  );
in
[
  (lib.nameValuePair args.pname kernelPackage)
  (lib.nameValuePair "${args.pname}-configfile" kernelPackage.configfile)
]
