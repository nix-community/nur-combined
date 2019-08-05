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
    ax88179_178a = { stdenv, fetchurl, fetchgit, linux }: let
      kernel = linux;
      patchsrc = fetchgit {
        url = https://aur.archlinux.org/asix-ax88179-dkms.git;
        rev = "38fdfbf2c04ee5576427eefffc6525ab581da7d5";
        sha256 = "0ndac9wxyhmsdjj7fnq37fd79ny5zrndqqbrkbj1xw5fn095g5b6";
      };
    in stdenv.mkDerivation rec {
        name = "ax88179-${version}-${kernel.version}";
        version = "1.19.0";

        src = fetchurl {
          url = "https://www.asix.com.tw/FrootAttach/driver/AX88179_178A_LINUX_DRIVER_v${version}_SOURCE.tar.bz2";
          sha256 = "17jc085ph17pwlzq0d5fsrqafyz5c8758c88mdbi05m95x7q64kj";
        };
        patches = [
          "${patchsrc}/0001-No-date-time.patch"
          "${patchsrc}/0002-b2b128.patch"
          "${patchsrc}/0003-linux-4.20.patch"
        ];

        hardeningDisable = [ "pic" ];

        kernelVersion = kernel.modDirVersion;

        makeFlags = [
          "KDIR=${kernel.dev}/lib/modules/$(kernelVersion)/build"
          "MDIR=drivers/net/usb"
          "SUBLEVEL=0"
        ];

        configurePhase = ''
          #kernel_version=${kernel.modDirVersion}
          #sed -i -e 's|/lib/modules|${kernel.dev}/lib/modules|' Makefile
          #export makeFlags="BUILD_KERNEL=$kernel_version CURRENT=$kernel_version MDIR=drivers/net/usb"
          #export makeFlags="KDIR=${kernel.dev}/lib/modules/$kernel_version/build MDIR=drivers/net/usb SUBLEVEL=0"
        '';

        installPhase = ''
          install -Dm644 -t $out/lib/modules/$kernelVersion/kernel/drivers/net/usb/ ax88179_178a.ko
        '';

        dontStrip = true;

        enableParallelBuilding = true;
        meta.platforms = stdenv.lib.platforms.linux;
      };
  };
#in (callPackage packages { })
in packages
