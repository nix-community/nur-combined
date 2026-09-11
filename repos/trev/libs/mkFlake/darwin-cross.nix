{ lib }:

let
  isLinuxToDarwin = localSystem: crossSystem: localSystem.isLinux && crossSystem.isDarwin;

  overlay =
    final: prev:
    let
      bootstrapAppleSdk = prev.apple-sdk.override { enableBootstrap = true; };
      overrideBintools =
        llvmPackages:
        llvmPackages.overrideScope (
          _llvmFinal: llvmPrev:
          let
            targetPrefix = llvmPrev.bintools-unwrapped.passthru.targetPrefix;
            # llvm-exegesis CPU-pinning checks hang in sandboxed Linux builds.
            withoutChecks =
              package:
              package.overrideAttrs (_: {
                doCheck = false;
              });
            crossLlvm = withoutChecks llvmPrev.llvm;
            crossLibllvm = withoutChecks llvmPrev.libllvm;
            crossLibunwind = llvmPrev.libunwind.override { doFakeLibgcc = false; };
            darwinLd = prev.buildPackages.writeShellScript "darwin-ld" ''
              set -eu

              minVersion=
              sdkVersion=
              args=()

              while [ "$#" -gt 0 ]; do
                case "$1" in
                  -macosx_version_min)
                    minVersion="$2"
                    shift 2
                    ;;
                  -sdk_version)
                    sdkVersion="$2"
                    shift 2
                    ;;
                  -z)
                    if [ "$#" -lt 2 ]; then
                      args+=("$1")
                      shift
                    else
                      case "$2" in
                        now|relro|text)
                          shift 2
                          ;;
                        *)
                          args+=("$1" "$2")
                          shift 2
                          ;;
                      esac
                    fi
                    ;;
                  -lrt)
                    shift
                    ;;
                  *)
                    args+=("$1")
                    shift
                    ;;
                esac
              done

              if [ -z "$minVersion" ] && [ -n "$sdkVersion" ]; then
                minVersion="''${MACOSX_DEPLOYMENT_TARGET:-$sdkVersion}"
              fi

              if [ -n "$minVersion" ]; then
                if [ -z "$sdkVersion" ]; then
                  sdkVersion="$minVersion"
                fi
                args+=("-platform_version" "macos" "$minVersion" "$sdkVersion")
              fi

              exec ${lib.getBin llvmPrev.lld}/bin/ld64.lld "''${args[@]}"
            '';
            darwinInstallNameTool = prev.buildPackages.writeShellScriptBin "install_name_tool" ''
              export LLVM_INSTALL_NAME_TOOL=${lib.escapeShellArg "${lib.getBin crossLlvm}/bin/llvm-install-name-tool"}
              export LDID=${lib.escapeShellArg "${lib.getBin prev.buildPackages.ldid}/bin/ldid"}
              exec ${prev.buildPackages.python3}/bin/python3 ${./darwin-install-name-tool.py} "$@"
            '';
            fixCompilerRt =
              package:
              package.overrideAttrs (old: {
                cmakeFlags = map (lib.replaceStrings
                  [ "/${targetPrefix}lipo" ]
                  [ "/${targetPrefix}llvm-lipo" ]
                ) old.cmakeFlags;
              });
          in
          {
            llvm = crossLlvm;
            libllvm = crossLibllvm;
            bintools-unwrapped = llvmPrev.bintools-unwrapped.overrideAttrs (old: {
              buildCommand = old.buildCommand + ''
                if [ -n ${lib.escapeShellArg old.passthru.targetPrefix} ]; then
                  ln -sf ${darwinInstallNameTool}/bin/install_name_tool \
                    "$out/bin/${old.passthru.targetPrefix}install_name_tool"
                  ln -sf ${lib.getBin crossLlvm}/bin/llvm-libtool-darwin \
                    "$out/bin/${old.passthru.targetPrefix}libtool"
                  ln -sf ${lib.getBin crossLlvm}/bin/llvm-lipo \
                    "$out/bin/${old.passthru.targetPrefix}lipo"
                  ln -sf ${lib.getBin crossLlvm}/bin/llvm-otool \
                    "$out/bin/${old.passthru.targetPrefix}otool"

                  ln -sf ${darwinInstallNameTool}/bin/install_name_tool "$out/bin/install_name_tool"
                  ln -sf ${lib.getBin crossLlvm}/bin/dsymutil "$out/bin/dsymutil"
                  ln -sf ${lib.getBin crossLlvm}/bin/llvm-libtool-darwin "$out/bin/libtool"
                  ln -sf ${lib.getBin crossLlvm}/bin/llvm-lipo "$out/bin/lipo"
                  ln -sf ${lib.getBin crossLlvm}/bin/llvm-otool "$out/bin/otool"
                  ln -sf ${darwinLd} "$out/bin/${old.passthru.targetPrefix}ld"
                fi
              '';
              passthru = old.passthru // {
                unsupportedHardeningFlags = (old.passthru.unsupportedHardeningFlags or [ ]) ++ [
                  "bindnow"
                  "relro"
                ];
              };
            });
            compiler-rt-libc = fixCompilerRt (
              llvmPrev.compiler-rt-libc.overrideAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ crossLibunwind ];
                # The inherited hook assumes ELF libatomic libraries and also
                # attempts to link Darwin's platform directory into itself.
                postInstall = ''
                  for library in "$out/lib"/*/*; do
                    if [ -f "$library" ]; then
                      ln -s "$library" "$out/lib"
                    fi
                  done
                '';
              })
            );
            compiler-rt-no-libc = fixCompilerRt llvmPrev.compiler-rt-no-libc;
            libunwind = crossLibunwind;
          }
        );
    in
    {
      apple-sdk = bootstrapAppleSdk;
      llvmPackages = final.llvmPackages_21;
      llvmPackages_21 = overrideBintools prev.llvmPackages_21;
    };

  fixPackage =
    packages: package:
    if package == null then
      null
    else if
      lib.isDerivation package
      && isLinuxToDarwin package.stdenv.buildPlatform package.stdenv.hostPlatform
      && lib.getName package != lib.getName packages.libiconv
    then
      package.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ packages.libiconv ];
      })
    else
      package;

  config = {
    allowUnsupportedSystem = true;

    replaceCrossStdenv =
      { baseStdenv, ... }:
      baseStdenv.override (old: {
        extraBuildInputs = map (
          package:
          if lib.isDerivation package && lib.getName package == "apple-sdk" then
            package.override { enableBootstrap = true; }
          else
            package
        ) (old.extraBuildInputs or [ ]);
      });
  };
in
{
  inherit
    config
    fixPackage
    isLinuxToDarwin
    overlay
    ;

  configureCrossSystem =
    localSystem: crossSystem:
    if isLinuxToDarwin localSystem crossSystem then
      crossSystem
      // {
        useLLVM = true;
        linker = "lld";
      }
    else
      crossSystem;
}
