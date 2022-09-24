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
  generateLinuxConfig = { stdenv, pkgs, lib, perl, gmp, libmpc, mpfr, flex ? null, bison ? null }:
    lib.drvExec "" (stdenv.mkDerivation {
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
    kernelMakeFlags = linux: [
      "-C" "${linux.dev}/lib/modules/${linux.modDirVersion}/build" "modules"
      "CROSS_COMPILE=${linux.stdenv.cc.targetPrefix or ""}"
      "M=$(NIX_BUILD_TOP)/$(sourceRoot)"
      "VERSION=$(version)"
    ] ++ (if linux.stdenv.hostPlatform ? linuxArch then [
      "ARCH=${linux.stdenv.hostPlatform.linuxArch}"
    ] else [ ]);
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
      sourceRoot = "source";

      nativeBuildInputs = [ makeWrapper ];
      shellPath = lib.makeBinPath [ kmod gnugrep coreutils ];

      kernelVersion = linux.modDirVersion;
      modules = [ "forcefully_remove_bootfb" ];
      makeFlags = kernelMakeFlags linux;
      enableParallelBuilding = true;

      outputs = [ "bin" "out" ];

      installPhase = ''
        install -Dm644 -t $out/lib/modules/$kernelVersion/kernel/drivers/video/fbdev/ forcefully_remove_bootfb.ko
        install -Dm755 forcefully_remove_bootfb.sh $bin/bin/forcefully-remove-bootfb
        wrapProgram $bin/bin/forcefully-remove-bootfb --prefix PATH : $shellPath
      '';

      dontStrip = true;
      meta.platforms = lib.platforms.linux;
    };

    ryzen-smu = { stdenv, lib, fetchFromGitLab, linux }: stdenv.mkDerivation rec {
      version = "2021-04-21";
      pname = let
        pname = "ryzen-smu";
        kernel-name = builtins.tryEval "${pname}-${linux.version}";
      in if kernel-name.success then kernel-name.value else pname;

      src = fetchFromGitLab {
        owner = "leogx9r";
        repo = "ryzen_smu";
        #rev = "v${version}";
        rev = "847caf27a1e05bfcb546e4456572ed2bc4ffd262";
        sha256 = "1xcrdwdkk7ijhiqix5rmz59cfps7p0x7gwflhqdcjm6np0ja3acv";
      };
      sourceRoot = "source";

      kernelVersion = linux.modDirVersion;
      modules = [ "ryzen-smu" ];
      makeFlags = kernelMakeFlags linux;
      enableParallelBuilding = true;

      installPhase = ''
        install -Dm644 -t $out/lib/modules/$kernelVersion/kernel/drivers/ ryzen_smu.ko
      '';

      meta.platforms = lib.platforms.linux;
    };

    rtl8189es = { stdenv, lib, fetchFromGitHub, linux }: stdenv.mkDerivation rec {
      version = "2021-10-01";
      pname = let
        pname = "rtl8189es";
        kernel-name = builtins.tryEval "${pname}-${linux.version}";
      in if kernel-name.success then kernel-name.value else pname;

      src = fetchFromGitHub {
        owner = "jwrdegoede";
        repo = "rtl8189ES_linux";
        rev = "be378f47055da1bae42ff6ec1d62f1a5052ef097";
        sha256 = "1szayxl5chvmylcla13s9dnfwd0g2k6zmn5bp7m1in5igganlpzv";
      };
      sourceRoot = "source";

      kernelVersion = linux.modDirVersion;
      modules = [ "8189es" ];
      makeFlags = kernelMakeFlags linux ++ [
        "CONFIG_RTL8189ES=m"
      ];
      enableParallelBuilding = true;

      installPhase = ''
        install -Dm644 -t $out/lib/modules/$kernelVersion/kernel/drivers/net/wireless 8189es.ko
      '';

      meta.platforms = lib.platforms.linux;
    };

    nvidia-patch = { stdenvNoCC, fetchFromGitHub, fetchpatch, writeShellScriptBin, lib, lndir, nvidia_x11 ? linuxPackages.nvidia_x11, linuxPackages ? { } }: let
      nvpatch = writeShellScriptBin "nvpatch" ''
        set -eu
        patchScript=$1
        objdir=$2

        set -- -sl
        source $patchScript

        patch="''${patch_list[$nvidiaVersion]-}"
        object="''${object_list[$nvidiaVersion]-}"

        if [[ -z $patch || -z $object ]]; then
          echo "$nvidiaVersion not supported for $patchScript" >&2
          exit 1
        fi

        sed -e "$patch" $objdir/$object.$nvidiaVersion > $object.$nvidiaVersion
      '';
    in stdenvNoCC.mkDerivation {
      pname = "nvidia-patch";
      version = "2022-09-22";

      src = fetchFromGitHub {
        # mirror: git clone https://ipfs.io/ipns/Qmed4r8yrBP162WK1ybd1DJWhLUi4t6mGuBoB9fLtjxR7u
        owner = "keylase";
        repo = "nvidia-patch";
        rev = "11231d117c89b239c76c817ff1060abd39916654";
        sha256 = "sha256-w8ezMJqiZZJYX50TLNmEGqRjL79LjD87vqAlykp6pHE=";
      };

      nativeBuildInputs = [ nvpatch lndir ];
      patchedLibs = [
        "libnvidia-encode${stdenvNoCC.hostPlatform.extensions.sharedLibrary}"
        "libnvidia-fbc${stdenvNoCC.hostPlatform.extensions.sharedLibrary}"
      ];

      inherit nvidia_x11;
      nvidia_x11_bin = nvidia_x11.bin;
      nvidia_x11_lib32 = nvidia_x11.lib32; # XXX: no patches for 32bit?
      nvidiaVersion = nvidia_x11.version;

      outputs = [ "out" "bin" "lib32" ];

      buildPhase = ''
        runHook preBuild

        nvpatch patch.sh $nvidia_x11/lib || nvenc=$?
        nvpatch patch-fbc.sh $nvidia_x11/lib || nvfbc=$?
        if [[ -n $nvenc && -n $nvfbc ]]; then
          exit 1
        fi

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        for f in $patchedLibs; do
          if [[ -e $f.$nvidiaVersion ]]; then
            install -Dm0755 -t $out/lib $f.$nvidiaVersion
          else
            echo WARN: $f not patched >&2
          fi
        done

        install -d $out $bin $lib32
        lndir -silent $nvidia_x11 $out

        ln -s $nvidia_x11_bin/* $bin/
        ln -s $nvidia_x11_lib32/* $lib32/

        runHook postInstall
      '';

      meta = with lib.licenses; {
        license = unfree;
      };
      passthru = {
        ci.cache.wrap = true;
        inherit (nvidia_x11) useProfiles persistenced settings bin lib32;
      };
    };
  };
in packages
