{
  callPackage,
  lib,
  sources,
  runCommandNoCC,
  ...
}:
args:
let
  helpers = callPackage ../../helpers/kernel { };
  inherit (helpers) mkKernel;

  splitted = lib.splitString "-" args.version;
  ver0 = builtins.elemAt splitted 0;
  ver1 = builtins.elemAt splitted 1;
  major = lib.versions.pad 2 ver0;

  combinedPatchFromCachyOS =
    let
      cachyDir = sources.cachyos-kernel-patches.src + "/${major}";
    in
    rec {
      name = "cachyos-patches-combined.patch";
      patch = runCommandNoCC name { } (
        ''
          for F in ${cachyDir}/*.patch; do
            case "$F" in
              # Patches already included in Xanmod
              *-bbr2.patch) continue;;
              *-bbr3.patch) continue;;
              *-futex-winesync.patch) continue;;
              *-amd-cache-optimizer.patch) continue;;

              # Patches that conflict with Xanmod
              *-cachy.patch) continue;;
              *-clr.patch) continue;;
              *-fixes.patch) continue;;
              *-mm-*.patch) continue;;
              *-t2.patch) continue;;
              ${lib.optionalString (lib.versionAtLeast major "6.11") "*-ntsync.patch) continue;;"}
            esac

            cat "$F" >> $out
          done
        ''
        + lib.optionalString (major == "6.11") ''
          if [ -f "${cachyDir}/sched/0001-sched-ext.patch" ]; then
            cat "${cachyDir}/sched/0001-sched-ext.patch" >> $out
          fi
        ''
      );
    };

  kernelPackage = mkKernel (
    lib.recursiveUpdate args {
      pname = "linux-xanmod-${args.pname}";
      modDirSuffix = "-lantian-${ver1}";
      extraPatches = [
        combinedPatchFromCachyOS
      ]
      ++ (args.extraPatches or [ ]);
      extraArgs = lib.recursiveUpdate {
        extraMeta = {
          description =
            "Linux Xanmod Kernel with Lan Tian Modifications"
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
