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

    forcefully-remove-bootfb = { stdenv, lib, fetchFromGitHub, linux, kmod, gnugrep, coreutils, makeWrapper }: stdenv.mkDerivation rec {
      version = "2018-02-08";
      pname = let
        name = "forcefully-remove-bootfb";
        kernel-name = builtins.tryEval "${name}-${linux.version}";
      in if kernel-name.success then kernel-name.value else name;

      src = fetchFromGitHub {
        owner = "arcnmx";
        repo = "arch-forcefully-remove-bootfb-dkms";
        rev = "2793a4b";
        sha256 = "1npbns5x2lssjxkqvj97bgi263l7zx6c9ij5r9ksbcdfpws5mmy5";
      };

      nativeBuildInputs = [ makeWrapper ];
      shellPath = lib.makeBinPath [ kmod gnugrep coreutils ];

      kernelVersion = linux.modDirVersion;
      modules = [ "forcefully_remove_bootfb" ];
      makeFlags = [
        "-C ${linux.dev}/lib/modules/${linux.modDirVersion}/build modules"
        "M=$(NIX_BUILD_TOP)/source"
      ];

      outputs = [ "bin" "out" ];

      installPhase = ''
        install -Dm644 -t $out/lib/modules/$kernelVersion/kernel/drivers/video/fbdev/ forcefully_remove_bootfb.ko
        install -Dm755 forcefully_remove_bootfb.sh $bin/bin/forcefully-remove-bootfb
        wrapProgram $bin/bin/forcefully-remove-bootfb --prefix PATH : $shellPath
      '';

      dontStrip = true;
      meta.platforms = lib.platforms.linux;
    };
  };
#in (callPackage packages { })
in packages
