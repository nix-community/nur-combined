{ pkgs, lib }:

let
  yogabook-src = pkgs.fetchgit {
    url = "https://github.com/jekhor/yogabook-linux.git";
    rev = "b699dfd21c0a1b4c32f4a6851e621b6324aa5f30";
    sha256 = "sha256-qTQZqHtNXoGbM9U4iASuobzOeypJiWf6sXQn2AiD+1A=";
    fetchSubmodules = true;
  };
in
{
  src = yogabook-src;

  touch-keyboard = pkgs.stdenv.mkDerivation {
    pname = "touch-keyboard-yogabook";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "jekhor";
      repo = "chromiumos_touch_keyboard";
      rev = "deccecb08889aa031664f5e22ec5c4c33fb6c41c";
      hash = "sha256-ASddTw/b6w29FxI+N66FwZCqJphQrprQPITHkYKMEtU=";
    };

    patches = [ ./touchpad-fix.patch ];

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
    ];
    buildInputs = with pkgs; [
      systemd
      udev
    ];

    postPatch = ''
      substituteInPlace CMakeLists.txt \
        --replace-warn "\''${UDEV_DIR}/rules.d" "lib/udev/rules.d" \
        --replace-warn "\''${UDEV_DIR}/hwdb.d" "lib/udev/hwdb.d" \
        --replace-warn "\''${SYSTEMD_SYSTEM_UNIT_DIR}" "lib/systemd/system"
    '';

    meta = with lib; {
      description = "Touch keyboard driver for Lenovo Yoga Book";
      homepage = "https://github.com/jekhor/chromiumos_touch_keyboard";
      license = licenses.bsd3;
      platforms = platforms.linux;
    };
  };

  yogabook-modes-handler = pkgs.stdenv.mkDerivation {
    pname = "yogabook-modes-handler";
    version = "1.0.0";

    src = "${yogabook-src}/yogabook-support";

    buildInputs = [
      (pkgs.python3.withPackages (
        ps: with ps; [
          evdev
          pyudev
        ]
      ))
    ];

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp yogabook-modes-handler $out/bin/
      chmod +x $out/bin/yogabook-modes-handler
    '';

    meta = with lib; {
      description = "Yoga Book modes handler";
      platforms = platforms.linux;
    };
  };

  iio-sensor-proxy-yogabook = pkgs.stdenv.mkDerivation {
    pname = "iio-sensor-proxy-yogabook";
    version = "3.1-patched";

    src = "${yogabook-src}/iio-sensor-proxy";

    nativeBuildInputs = with pkgs; [
      meson
      ninja
      pkg-config
      gobject-introspection
    ];
    buildInputs = with pkgs; [
      glib
      systemd
      libgudev
      polkit
    ];

    PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";
    PKG_CONFIG_UDEV_UDEVDIR = "${placeholder "out"}/lib/udev";

    meta = with lib; {
      description = "Patched IIO sensor proxy for Lenovo Yoga Book hinge and tablet mode";
      homepage = "https://gitlab.freedesktop.org/jekhor/iio-sensor-proxy";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };

  yogabook-config = pkgs.runCommandCC "yogabook-kernel-config" {
    nativeBuildInputs = with pkgs; [ gnumake bison flex elfutils perl ];
  } ''
    cp -r ${yogabook-src}/yogabook-linux-kernel/* .
    chmod -R +w .
    make ARCH=x86 yogabook_defconfig
    cp .config $out
  '';

  yogabook-modules = { kernel, kernelModuleMakeFlags, enableHapticCalibration ? false, enableAudio ? true }: pkgs.stdenv.mkDerivation {
    pname = "yogabook-modules";
    version = kernel.version;

    src = yogabook-src;

    nativeBuildInputs = kernel.moduleBuildDependencies;

    preConfigure = ''
      patch -p1 -i ${./yogabook-wmi-power.patch}
      patch -p1 -i ${./backlight-initrd-fix.patch}
      
      # Prepare platform/input modules
      cp yogabook-linux-kernel/drivers/platform/x86/serdev_helpers.h .
      mkdir build-platform
      cp -r yogabook-linux-kernel/drivers/platform/x86/x86-android-tablets/* build-platform/
      cp yogabook-linux-kernel/drivers/input/misc/drv260x.c build-platform/
      cp yogabook-linux-kernel/drivers/platform/x86/lenovo/yogabook.c build-platform/
      substituteInPlace build-platform/lenovo.c \
        --replace-fail 'PROPERTY_ENTRY_U32("mode", 0),' 'PROPERTY_ENTRY_U32("mode", ${if enableHapticCalibration then "0" else "1"}),'
      
      cat << 'EOF' > build-platform/Makefile
      obj-m += vexia_atla10_ec.o
      obj-m += x86-android-tablets.o
      x86-android-tablets-y := core.o dmi.o shared-psy-info.o asus.o lenovo.o other.o
      obj-m += drv260x.o
      obj-m += lenovo-yogabook.o
      lenovo-yogabook-y := yogabook.o
      EOF
    '' + lib.optionalString enableAudio ''
      # Prepare sound machine driver in its original directory
      cat << 'EOF' > yogabook-linux-kernel/sound/soc/intel/boards/Makefile
      obj-m += snd-soc-sst-cht-yogabook.o
      snd-soc-sst-cht-yogabook-y := cht_yogabook.o
      EOF

      # Adapt cht_yogabook.c to newer kernel APIs (include soc-dapm.h, use encapsulating helpers, disable spi_register_board_info)
      substituteInPlace yogabook-linux-kernel/sound/soc/intel/boards/cht_yogabook.c \
        --replace-fail 'cht_codec_register_spidev();' '// cht_codec_register_spidev();' ${lib.optionalString (lib.versionAtLeast kernel.version "6.13") ''
        --replace-fail '#include <sound/soc-acpi.h>' $'#include <sound/soc-acpi.h>\n#include <sound/soc-dapm.h>' \
        --replace-fail 'dapm->card' 'snd_soc_dapm_to_card(dapm)' \
        --replace-fail '&jack->card->dapm' 'snd_soc_card_to_dapm(jack->card)'
      ''}

      # Prepare ACPI match module in its original directory by overwriting the Makefile to only build CHT/BYT match files (prevents compile errors on new kernels)
      cat << 'EOF' > yogabook-linux-kernel/sound/soc/intel/common/Makefile
      obj-m += snd-soc-acpi-intel-match.o
      snd-soc-acpi-intel-match-y := soc-acpi-intel-byt-match.o soc-acpi-intel-cht-match.o soc-acpi-intel-ssp-common.o stubs.o
      EOF

      # Fix EXPORT_SYMBOL_NS namespace string literal compilation error on kernel 6.12
      substituteInPlace yogabook-linux-kernel/sound/soc/intel/common/soc-acpi-intel-ssp-common.c \
        --replace-fail '"SND_SOC_ACPI_INTEL_MATCH"' 'SND_SOC_ACPI_INTEL_MATCH'

      # Write stubs.c for other platforms to resolve all symbol dependencies of snd_intel_sst_acpi
      cat << 'EOF' > yogabook-linux-kernel/sound/soc/intel/common/stubs.c
      #include <sound/soc-acpi.h>
      #include <linux/module.h>

      struct snd_soc_acpi_mach snd_soc_acpi_intel_broadwell_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_broadwell_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_bxt_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_bxt_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_cml_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_cml_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_cml_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_cml_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_cnl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_cnl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_cnl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_cnl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_ehl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_ehl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_glk_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_glk_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_hda_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_hda_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_icl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_icl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_icl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_icl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_jsl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_jsl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_kbl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_kbl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_lnl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_lnl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_mtl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_mtl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_mtl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_mtl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_nvl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_nvl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_nvl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_nvl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_ptl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_ptl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_ptl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_ptl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_rpl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_rpl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_rpl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_rpl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_skl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_skl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_tgl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_tgl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_tgl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_tgl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_adl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_adl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_adl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_adl_sdw_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_arl_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_arl_machines);

      struct snd_soc_acpi_mach snd_soc_acpi_intel_arl_sdw_machines[] = { {} };
      EXPORT_SYMBOL_GPL(snd_soc_acpi_intel_arl_sdw_machines);
      EOF

      echo 'MODULE_LICENSE("GPL");' >> yogabook-linux-kernel/sound/soc/intel/common/soc-acpi-intel-cht-match.c
      echo 'MODULE_DESCRIPTION("Intel Common ACPI Match module");' >> yogabook-linux-kernel/sound/soc/intel/common/soc-acpi-intel-cht-match.c
    '';

    buildPhase = ''
      runHook preBuild
      
      echo "Building platform/input modules..."
      make ${lib.escapeShellArgs kernelModuleMakeFlags} -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd)/build-platform modules
    '' + lib.optionalString enableAudio ''
      echo "Building sound machine driver..."
      make ${lib.escapeShellArgs kernelModuleMakeFlags} -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd)/yogabook-linux-kernel/sound/soc/intel/boards modules
      
      echo "Building ACPI match module..."
      make ${lib.escapeShellArgs kernelModuleMakeFlags} -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd)/yogabook-linux-kernel/sound/soc/intel/common modules
    '' + ''
      runHook postBuild
    '';

    installPhase = ''
      mkdir -p $out/lib/modules/${kernel.modDirVersion}/updates
      find . -name '*.ko' -exec cp '{}' $out/lib/modules/${kernel.modDirVersion}/updates/ \;
      find $out/lib/modules/${kernel.modDirVersion}/updates/ -name '*.ko' -exec xz -f '{}' \;
    '';

    meta = {
      description = "Patched kernel modules for Lenovo Yoga Book (x86-android-tablets, drv260x)";
      license = lib.licenses.gpl2Only;
      platforms = lib.platforms.linux;
    };
  };
}
