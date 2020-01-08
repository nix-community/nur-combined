let
  mergeLinuxConfig = { wrapShellScriptBin, fetchurl, stdenvNoCC, makeWrapper, bash, lib, coreutils, gnused, gnugrep, gnumake, flex ? null, bison ? null }: let
    src = fetchurl {
      url = https://github.com/torvalds/linux/raw/v5.0/scripts/kconfig/merge_config.sh;
      sha256 = "063v44ffcs24x0ywj4xklglkvm62n2m690gd9pdj00wpbz7z3hni";
    };
  in wrapShellScriptBin "merge_config.sh" src {
    depsRuntimePath = [
      coreutils gnused gnugrep gnumake flex bison
    ];
  };
  generateLinuxConfig = { stdenv, pkgs, perl, gmp, libmpc, mpfr, flex ? null, bison ? null }:
    pkgs.lib.drvExec "" (stdenv.mkDerivation {
      name = "generate-config.pl";
      src = pkgs.path + "/pkgs/os-specific/linux/kernel/generate-config.pl";
      patches = [ ./generate-config.patch ];
      propagatedBuildInputs = [ gmp libmpc mpfr flex bison ];
      buildInputs = [ perl ];
      unpackPhase = "true";
      patchPhase = ''
        patch -o - -i "$patches" $src > generate-config.pl
      '';
      installPhase = ''
        install -Dm0755 generate-config.pl $out/bin/$name
      '';
      passthru = {
        phase = {
          # TODO: a setup hook instead of this
          patch = ''
            # Patch kconfig to print "###" after every question so that generate-config.pl from the generic builder can answer them.
            sed -e '/fflush(stdout);/i\printf("###");' -i scripts/kconfig/conf.c
          '';
          build = ''
            echo "generating kernel configuration..."
            sed \
              -e 's/^CONFIG_\([^=]\+\)=/\1 /' \
              -e 's/^# CONFIG_\([^ ]\+\) is not set$/\1 n/' \
              < $kernelConfigPath > ''${kernelBuildRoot-$PWD}/config.legacynix
            DEBUG=1 ARCH=$kernelArch \
              KERNEL_CONFIG="''${kernelBuildRoot-$PWD}/config.legacynix" \
              AUTO_MODULES=''${kernelAutoModules-} PREFER_BUILTIN=''${kernelPreferBuiltin-} \
              ignoreConfigErrors=''${ignoreConfigErrors-0} \
              BUILD_ROOT="''${kernelBuildRoot-$PWD}" SRC=. \
              generate-config.pl
          '';
        };
      };
    });
  packages = {
    inherit mergeLinuxConfig generateLinuxConfig;
  };
#in (callPackage packages { })
in packages
