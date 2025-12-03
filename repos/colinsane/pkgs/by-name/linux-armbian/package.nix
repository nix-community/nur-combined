{
  fetchFromGitHub,
  fetchurl,
  lib,
  linux_latest,
  linux-mobian,
  linux-postmarketos-allwinner,
  newScope,
  sane-kernel-tools,
  usePmosConfig ? false,
  withNixpkgsConfig ? true,
  withFullConfig ? true,
  withModemPower ? false,
  withArmbianPatches ? false,
  withMegousPatches ? true,
  withMobianPatches ? false,
  #VVV nixpkgs calls `.override` on the kernel to configure additional things, but we don't care about those things
  ...
}:
let
  linux = linux_latest;
  patches = import ./patches.nix { inherit fetchFromGitHub lib newScope; };
  nullPatch = {
    name = "null-patch";
    patch = null;
  };
in
linux.override {
  # inherit (linux_latest) src version modDirVersion;
  # inherit features randstructSeed structuredExtraConfig;

  DTB = true;  #< XXX: not sure if actually needed
  autoModules   = withFullConfig;
  preferBuiltin = true;

  enableCommonConfig = withNixpkgsConfig;

  # kernelPatches = patches.megous.series ++
  kernelPatches = [
    {
      # alternative anx7688 driver than what's in megi's tree.
      # this one is observed to have > 1A inbound current though, seems fine.
      name = "usb: typec: anx7688: Add driver for ANX7688 USB-C HDMI bridge";
      patch = fetchurl {
        # https://lore.kernel.org/lkml/ZhPM4XU8ttsFftBd@duo.ucw.cz/
        name = "usb: typec: anx7688: Add driver for ANX7688 USB-C HDMI bridge";
        url = "http://lore.kernel.org/lkml/ZhPM4XU8ttsFftBd@duo.ucw.cz/1-a.txt";
        hash = "sha256-doJOtaJLvepgagkQH0oqzVR9VQY4ZbK/3gx4kKgKnLg=";
      };
    }
  ]
  ++ lib.optionals withMobianPatches (with linux-mobian.patches.pinephone; [
    byName."0132-regulator-axp20x-Turn-N_VBUSEN-to-input-on-x-powers-"
    byName."0133-arm64-dts-sun50i-a64-pinephone-Add-front-back-camera"
    # byName."0134-arm64-dts-sun50i-a64-pinephone-Add-Type-C-support-fo"  #< `Error: ../arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone.dtsi:578.1-12 Label or path sound_hdmi not found`
    # byName."0135-arm64-dts-sun50i-a64-pinephone-Add-detailed-OCV-to-c"
    # byName."0136-arm64-dts-sun50i-a64-pinephone-Add-mount-matrix-for-"
    # byName."0137-arm64-dts-sun50i-a64-pinephone-Add-support-for-Bluet"
    # byName."0138-arm64-dts-sun50i-a64-pinephone-Enable-internal-HMIC-"
    # byName."0139-arm64-dts-sun50i-a64-pinephone-Add-support-for-modem"
    # byName."0140-arm64-dts-sun50i-a64-pinephone-Bump-I2C-frequency-to"
    # byName."0141-arm64-dts-sun50i-a64-pinephone-Add-interrupt-pin-for"
    # byName."0142-arm64-dts-sun50i-a64-pinephone-Don-t-make-lradc-keys"
    # byName."0143-arm64-dts-sun50i-a64-pinephone-Add-supply-for-i2c-bu"
    # byName."0144-arm64-dts-sun50i-a64-pinephone-Workaround-broken-HDM"
    # byName."0145-arm64-dts-sun50i-a64-pinephone-Add-AF8133J-to-PinePh"
    # byName."0146-arm64-dts-sun50i-a64-pinephone-Add-mount-matrix-for-"
    # byName."0147-arm64-dts-sun50i-a64-pinephone-Add-support-for-Pinep"
    # byName."0148-arm64-dts-sun50i-a64-Add-missing-trip-points-for-GPU"
    # byName."0149-arm64-dts-allwinner-sun50i-a64-pinephone-Add-support"
    # byName."0150-ARM-dts-allwinner-sun50i-64-pinephone-Add-power-supp"
    # byName."0151-arm64-dts-sun50i-a64-pinephone-Power-off-the-touch-c"
    # byName."0152-arm64-dts-allwinner-pinephone-Add-modem-EG25-G-suppo"
    # byName."0153-arm64-dts-sun50i-pinephone-add-near-level-to-proximi"
    # byName."0154-arm64-dts-allwinner-pinephone-lower-cpu_alert-temper"
    # byName."0155-arm64-dts-allwinner-pinephone-change-backlight-brigh"
    # byName."0156-arm64-dts-allwinner-pinephone-fix-headphone-jack-nam"
    # byName."0157-arm64-dts-pinephone-Add-pstore-support-for-PinePhone"
    # byName."0158-arm64-dts-allwinner-pinephone-Set-orientation-for-fr"
  ])
  ++ lib.optionals withArmbianPatches (with patches.armbian; [
    byName."Doc-dt-bindings-usb-add-binding-for-DWC3-controller-on-Allwinne"
    byName."drv-pinctrl-pinctrl-sun50i-a64-disable_strict_mode"
    byName."drv-rtc-sun6i-support-RTCs-without-external-LOSCs"
    byName."drv-gpu-drm-gem-dma-Export-with-handle-allocator"
    byName."drv-gpu-drm-sun4i-Add-GEM-allocator"
    byName."Revert-drm-sun4i-hdmi-switch-to-struct-drm_edid"
    byName."drv-gpu-drm-sun4i-Add-HDMI-audio-sun4i-hdmi-encoder"
    byName."drv-net-stmmac-dwmac-sun8i-second-EMAC-clock-register"
    byName."drv-phy-sun4i-usb-Allow-reset-line-to-be-shared"
    byName."drv-staging-media-sunxi-cedrus-add-H616-variant"
    byName."drv-soc-sunxi-sram-Add-SRAM-C1-H616-handling"
    byName."drv-media-dvb-frontends-si2168-fix-cmd-timeout"
    byName."include-uapi-drm_fourcc-add-ARM-tiled-format-modifier"
    byName."drv-clocksource-arm_arch_timer-fix-a64-timejump"
    byName."sound-soc-sunxi-sun4i-spdif-add-mclk_multiplier"
    byName."sound-soc-sunxi-sun8i-codec-analog-enable-sound"
    # byName."sound-soc-sunxi-Provoke-the-early-load-of-sun8i-codec-analog"  #< 2024-09-16: does not apply to linux 6.11.0
    byName."sound-soc-sunxi-sun4i-codec-adcis-select-capture-source"
    byName."drv-mmc-host-sunxi-mmc-add-h5-emmc-compatible"
    byName."drv-pinctrl-sunxi-pinctrl-sun50i-h6.c-GPIO-disable_strict_mode"
    byName."drv-gpu-drm-sun4i-sun8i_mixer.c-add-h3-mixer1"
    byName."drv-mtd-nand-raw-nand_ids.c-add-H27UBG8T2BTR-BC-nand"
    byName."drv-mfd-axp20x-add-sysfs-interface"
    byName."drv-spi-spidev-Add-armbian-spi-dev-compatible"
    byName."drv-spi-spi-sun4i.c-spi-bug-low-on-sck"
    byName."drv-rtc-sun6i-Add-Allwinner-H616-support"
    byName."drv-nvmem-sunxi_sid-Support-SID-on-H616"
    byName."drv-iio-adc-axp20x_adc-arm64-dts-axp803-hwmon-enable-thermal"
    byName."drv-gpu-drm-panel-simple-Add-compability-olinuxino-lcd"
    byName."drv-input-touchscreen-sun4i-ts-Enable-parsing"
    byName."drv-mmc-host-sunxi-mmc-Disable-DDR52-mode-on-all-A20-based-boar"
    byName."drv-usb-gadget-composite-rename-gadget-serial-console-manufactu"
    byName."arm-arm64-dts-Add-leds-axp20x-charger"
    byName."arm-dts-sun9i-a80-add-thermal-sensor"
    byName."arm-dts-sun9i-a80-add-thermal-zone"
    byName."arm-dts-sun7i-a20-Disable-OOB-IRQ-for-brcm-wifi-on-Cubietruck-a"
    byName."arm-dts-a20-orangepi-and-mini-fix-phy-mode-hdmi"
    byName."arm-dts-sun8i-h3-nanopi-add-leds-pio-pins"
    byName."arm-dts-a10-cubiebord-a20-cubietruck-green-LED-mmc0-default-tri"
    byName."arm-dts-Add-sun8i-h2-plus-nanopi-duo-device"
    byName."arm-dts-Add-sun8i-h2-plus-sunvell-r69-device"
    byName."arm-dts-h3-nanopi-neo-Add-regulator-leds-mmc2"
    byName."arm-dts-h3-nanopi-neo-air-Add-regulator-camera-wifi-bluetooth-o"
    byName."arm-dts-h3-orangepi-2-Add-regulator-vdd-cpu"
    byName."arm-dts-sun8i-r40-bananapi-m2-ultra-add-codec-analog"
    byName."arm-dts-sun7i-a20-cubietruck-add-alias-uart2"
    byName."arm-dts-sun8i-v3s-s3-pinecube-enable-sound-codec"
    byName."arm-dts-sun8i-r40-add-clk_out_a-fix-bananam2ultra"
    byName."arm-dts-sun8i-h3-bananapi-m2-plus-add-wifi_pwrseq"
    byName."arm-dts-sun7i-a20-bananapro-add-hdmi-connector-de"
    byName."arm-dts-sun7i-a20-bananapro-add-AXP209-regulators"
    byName."arm-dts-sunxi-h3-h5.dtsi-force-mmc0-bus-width"
    byName."arm64-dts-sun50i-a64-pine64-enable-wifi-mmc1"
    byName."arm64-dts-sun50i-a64-sopine-baseboard-Add-i2s2-mmc1"
    byName."arm64-dts-sun50i-h6-Add-r_uart-uart2-3-pins"
    byName."arm64-dts-allwiner-sun50i-h616.dtsi-add-usb-ehci-ohci"
    byName."arm64-dts-sun50i-h616-orangepi-zero2-reg_usb1_vbus-status-ok"
    byName."arm64-dts-allwinner-sun50i-h616-Add-GPU-node"
    byName."arm64-dts-sun50i-h616-orangepi-zero2-Enable-GPU-mali"
    byName."arm64-dts-allwinner-sun50i-h616-Add-VPU-node"
    byName."arm64-dts-sun50i-h616-x96-mate-T95-eth-sd-card-hack"
    byName."arm64-dts-sun50i-h616-x96-mate-add-hdmi"
    byName."arm64-dts-add-sun50i-h618-cpu-dvfs.dtsi"
    byName."arm64-dts-sun50i-h313-x96q-lpddr3"
    byName."Add-FB_TFT-ST7796S-driver"
    byName."Optimize-TSC2007-touchscreen-add-polling-method"
    byName."Add-ws2812-RGB-driver-for-allwinner-H616"
    byName."LED-green_power_on-red_status_heartbeat-arch-arm64-boot-dts-all"
    byName."arm64-dts-allwinner-h616-orangepi-zero2-Enable-expansion-board-"
    byName."arm64-dts-sun50i-a64-pine64-enable-Bluetooth"
    byName."arm64-dts-sun50i-a64-sopine-baseboard-enable-Bluetooth"
    byName."arm64-dts-nanopi-a64-set-right-phy-mode-to-rgmii-id"
    byName."arm64-dts-FIXME-a64-olinuxino-add-regulator-audio-mmc"
    byName."arm64-dts-Add-sun50i-h5-nanopi-k1-plus-device"
    byName."arm64-dts-Add-sun50i-h5-nanopi-neo-core2-device"
    byName."arm64-dts-Add-sun50i-h5-nanopi-neo2-v1.1-device"
    byName."arm64-dts-Add-sun50i-h5-nanopi-m1-plus2-device"
    byName."arm64-dts-sun50i-h5-nanopi-neo2-add-regulator-led-triger"
    byName."arm64-dts-sun50i-h5-orangepi-pc2-add-spi-flash"
    byName."arm64-dts-sun50i-h5-orangepi-prime-add-regulator"
    byName."arm64-dts-sun50i-h5-orangepi-zero-plus-add-regulator"
    byName."arm64-dts-sun50i-h6.dtsi-improve-thermals"
    byName."arm64-dts-sun50i-h6-orangepi-3-delete-node-spi0"
    byName."arm64-dts-sun50i-h6-orangepi-lite2-spi0-usb3phy-dwc3-enable"
    byName."arm64-dts-sun50i-h6-pine-h64-add-wifi-rtl8723cs"
    byName."arm64-dts-sun50i-h6-pine-h64-add-dwc3-usb3phy"
    byName."arm64-dts-sun50i-a64-pine64-add-spi0"
    byName."arm64-dts-sun50i-h6.dtsi-add-pinctrl-pins-for-spi"
    byName."arm64-dts-sun50i-a64-orangepi-win-add-aliase-ethernet1"
    byName."arm64-dts-sun50i-a64-force-mmc0-bus-width"
    byName."drv-of-Device-Tree-Overlay-ConfigFS-interface"
    # byName."scripts-add-overlay-compilation-support"  #< error: "mkimage: command not found"
    byName."Makefile-CONFIG_SHELL-fix-for-builddeb-packaging"
    byName."arm-dts-overlay-Add-Overlays-for-sunxi"
    byName."arm64-dts-allwinner-overlay-Add-Overlays-for-sunxi64"
    byName."arm-dts-overlay-sun8i-h3-cpu-clock-add-overclock"
    byName."arm64-dts-overlay-sun50i-a64-pine64-7inch-lcd"
    byName."arm64-dts-overlay-sun50i-h5-add-gpio-regulator-overclock"
    byName."Move-sun50i-h6-pwm-settings-to-its-own-overlay"
    byName."Compile-the-pwm-overlay"
    byName."cb1-overlay"
    byName."cb1-overlay-light-fix"
    byName."arm-dts-sunxi-h3-h5.dtsi-add-i2s0-i2s1-pins"
    byName."arm-dts-sun5i-a13-olinuxino-micro-add-panel-lcd-olinuxino-4.3"
    byName."arm-dts-sun5i-a13-olinuxino-Add-panel-lcd-olinuxino-4.3-needed-"
    byName."arm-dts-sun7i-a20-olinuxino-micro-emmc-Add-vqmmc-node"
    byName."arm-dts-sun7i-a20-olinuxino-lime2-enable-audio-codec"
    byName."arm-dts-sun7i-a20-olinuxino-lime2-enable-ldo3-always-on"
    byName."arm-dts-sun7i-a20-olimex-som-204-evb-olinuxino-micro-decrease-d"
    byName."arm-dts-sun8i-h3-add-thermal-zones"
    byName."arm64-dts-sun50i-a64-olinuxino-add-boards"
    byName."arm64-dts-sun50i-a64-olinuxino-emmc-enable-bluetooth"
    byName."arm64-dts-sun50i-a64-olinuxino-1Ge16GW-enable-bluetooth"
    byName."arm64-dts-sun50i-a64.dtsi-adjust-thermal-trip-points"
    byName."arm64-dts-sun50i-a64-olinuxino-1Ge16GW-Disable-clock-phase-and-"
    # byName."Temp_fix-mailbox-arch-arm64-boot-dts-allwinner-sun50i-a64-pinep"  #< 2024-09-16: does not apply to linux 6.11.0
    # byName."arm64-dts-sun50i-h6-orangepi-3-add-r_uart-aliase"  #< 2024-09-16: does not apply to linux 6.11.0
    byName."arm64-dts-sun50i-h5-add-cpu-opp-refs"
    byName."arm64-dts-sun50i-h5-add-termal-zones"
    byName."arm64-dts-sun50i-h6-orangepi-add-cpu-opp-refs"
    byName."arm64-dts-sun50i-h6-orangepi-enable-higher-clock-regulator-max-"
    byName."drv-staging-rtl8723bs-AP-bugfix"
    byName."arm-dts-sun8i-h3-orangepi-pc-plus-add-wifi_pwrseq"
    byName."arm64-dts-sun50i-h5-orangepi-prime-add-rtl8723cs"
    byName."arm-dts-sun8i-h2-plus-orangepi-zero-fix-xradio-interrupt"
    byName."Fix-include-uapi-spi-spidev-module"
    # byName."fix-cpu-opp-table-sun8i-a83t"  #< 2024-09-16: does not apply to linux 6.11.0
    # byName."Add-dump_reg-and-sunxi-sysinfo-drivers"  #< 2024-09-16: compile error in sunxi-sysinfo.c for linux 6.11.0
    # byName."Add-sunxi-addr-driver-Used-to-fix-uwe5622-bluetooth-MAC-address"  #< 2024-09-16: does not apply to linux 6.11.0
    byName."nvmem-sunxi_sid-add-sunxi_get_soc_chipid-sunxi_get_serial"
    byName."mmc-host-sunxi-mmc-Fix-H6-emmc"
    byName."arm64-dts-allwinner-sun50i-h6-Fix-H6-emmc"
    byName."arm64-dts-sun50i-h5-nanopi-r1s-h5-add-rtl8153-support"
    byName."net-usb-r8152-add-LED-configuration-from-OF"
    byName."arm64-dts-sun50i-h6-orangepi.dtsi-Rollback-r_rsb-to-r_i2c"
    byName."arm64-dts-sun50i-h616-bigtreetech-cb1-sd-emmc"
    byName."arch-arm64-dts-allwinner-sun50i-h618-bananapi-m4-zero"
    byName."ARM-dts-sun8i-nanopiduo2-Use-key-0-as-power-button"
    byName."ARM-dts-sun8i-nanopiduo2-enable-ethernet"
    # byName."arm-dts-sun8i-h3-reduce-opp-microvolt-to-prevent-not-supported-"  #< 2024-09-16: does not apply to linux 6.11.0
    byName."arm64-dts-sun50i-h5-enable-power-button-for-orangepi-prime"
    byName."enable-TV-Output-on-OrangePi-Zero-LTE"
    byName."drivers-devfreq-sun8i-a33-mbus-disable-autorefresh"
    # byName."clk-gate-add-support-for-regmap-based-gates"  #< 2024-09-16: compile error for linux 6.11.0, in clk-provider.h
    byName."mfd-Add-support-for-X-Powers-AC200"
    byName."mfd-Add-support-for-X-Powers-AC200-EPHY-syscon"
    byName."net-phy-Add-support-for-AC200-EPHY"
    byName."arm64-dts-allwinner-h6-Add-AC200-EPHY-nodes"
    byName."arm64-dts-allwinner-h6-tanix-enable-Ethernet"
    byName."ASoC-AC200-Initial-driver"
    byName."arm64-dts-allwinner-h6-add-AC200-codec-nodes"
    byName."arm64-dts-allwinner-h6-enable-AC200-codec"
    byName."add-nodes-for-sunxi-info-sunxi-addr-and-sunxi-dump-reg"
    # byName."add-initial-support-for-orangepi3-lts"  #< 2024-09-16: DTS fails with unknown reference to sound_hdmi node
    byName."Input-axp20x-pek-allow-wakeup-after-shutdown"
    # byName."Add-wifi-nodes-for-Inovato-Quadra"  #< 2024-09-16: DTS fails with unknown reference to sound_hdmi node
    byName."arm64-dts-h616-add-wifi-support-for-orange-pi-zero-2-and-zero3"
    byName."arm64-dts-sun50i-h618-orangepi-zero3-Enable-GPU-mali"
    byName."arm64-dts-h616-add-hdmi-support-for-zero2-and-zero3"
    byName."arm64-dts-H616-Add-overlays-that-are-also-compatible-with-orang"
    byName."driver-allwinner-h618-emac"
    byName."drivers-pwm-Add-pwm-sunxi-enhance-driver-for-h616"
    byName."arm64-dts-sun50i-h618-orangepi-zero2w-Add-missing-nodes"
    byName."arch-arm64-dts-allwinner-sun50i-h616-PG-12c-pins"
    byName."arch-arm64-dts-allwinner-sun50i-h616-spi1-cs1-pin"
    byName."add-dtb-overlay-for-zero2w"
    # byName."Sound-for-H616-H618-Allwinner-SOCs"  #< 2024-09-16: does not apply to linux 6.11.0
    byName."ARM64-dts-sun50i-h616-BigTreeTech-CB1-Enable-HDMI"
    byName."ARM64-dts-sun50i-h616-BigTreeTech-CB1-Enable-EMAC1"
  ])
  ++ lib.optionals withMegousPatches (with patches.megous; [
    # subset of megi patches.
    # as you edit this, ensure:
    # - front and back camera still work in megapixels/snapshot.
    # - battery is still chargable (`cat /sys/class/power_supply/axp20x-battery/current-now` reports positive when plugged in)
    # these ov5640 patches are necessary for EITHER camera to register (2024-09-15)
    # byName."media-ov5640-Experiment-Try-to-disable-denoising-sharpening"
    # byName."media-ov5640-Sleep-after-poweroff-to-ensure-next-poweron-is-not"
    # byName."media-ov5640-Don-t-powerup-the-sensor-during-driver-probe"
    # byName."media-ov5640-set-default-ae-target-lower"
    # byName."media-ov5640-Improve-error-reporting"
    # byName."media-ov5640-Implement-autofocus"
    # byName."media-ov5640-Improve-firmware-load-time"
    # byName."media-ov5640-Fix-focus-commands-blocking-until-complete"
    # byName."media-ov5640-Add-read-only-property-for-vblank"
    # byName."media-ov5640-use-pm_runtime_force_suspend-resume-for-system-sus"
    # byName."media-sun6i-csi-capture-Use-subdev-operation-to-access-bridge-f"
    # byName."media-sun6i-csi-subdev-Use-subdev-active-state-to-store-active-"
    # byName."media-sun6i-csi-merge-sun6i_csi_formats-and-sun6i_csi_formats_m"
    # byName."media-sun6i-csi-add-V4L2_CAP_IO_MC-capability"
    # byName."media-sun6i-csi-implement-vidioc_enum_framesizes"
    # byName."media-sun6i-csi-Add-multicamera-support-for-parallel-bus"
    # # byName."nfc-pn544-Add-support-for-VBAT-PVDD-regulators"
    # # byName."bluetooth-bcm-Restore-drive_rts_on_open-true-behavior-on-bcm207"
    # # byName."mmc-add-delay-after-power-class-selection"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Add-PN544-NFC-support"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Add-powerup-down-support-for-the-3G"
    # # byName."ARM-dts-sun8i-a83t-Add-cedrus-video-codec-support-to-A83T-untes"
    # # byName."ARM-dts-suni-a83t-Add-i2s0-pins"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Add-sound-support-via-AC100-codec"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Add-regulators-to-the-accelerometer"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Add-camera-sensors-HM5065-GC2145"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Add-flash-led-support"
    # byName."dt-bindings-input-gpio-vibrator-Don-t-require-enable-gpios"
    # byName."input-gpio-vibra-Allow-to-use-vcc-supply-alone-to-control-the-v"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Add-support-for-the-vibrator-motor"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Increase-voltage-on-the-vibrator"
    # # byName."dt-bindings-leds-Add-a-binding-for-AXP813-charger-led"
    # # byName."leds-axp20x-Support-charger-LED-on-AXP20x-like-PMICs"
    # # byName."ARM-dts-axp813-Add-charger-LED"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Enable-charging-LED"
    # # byName."MAINTAINERS-Add-entry-for-Himax-HM5065"
    # # byName."dt-bindings-media-Add-bindings-for-Himax-HM5065-camera-sensor"
    # # byName."hm5065-yaml-bindings-wip"
    # # i believe these gc2145 patches are required for either camera to register (?) (2024-09-15)
    # # byName."media-hm5065-Add-subdev-driver-for-Himax-HM5065-camera-sensor"  #< required for later patch to apply: media-gc2145-Galaxycore-camera-module-driver
    # # byName."media-i2c-gc2145-Move-upstream-driver-out-of-the-way"  #< linux 6.11.0: doesn't apply
    # # byName."media-gc2145-Galaxycore-camera-module-driver"
    # # byName."media-gc2145-Added-BGGR-bayer-mode"
    # # byName."media-gc2145-Disable-debug-output"
    # # byName."media-gc2145-Add-PIXEL_RATE-HBLANK-and-VBLANK-controls"
    # # byName."media-gc2145-implement-system-suspend"
    # # byName."media-gc2145-fix-white-balance-colors"
    # # byName."media-i2c-gc2145-Parse-and-register-properties"
    # # byName."mailbox-Allow-to-run-mailbox-while-timekeeping-is-suspended"
    # # byName."ARM-sunxi-Add-experimental-suspend-to-memory-implementation-for"
    # # byName."ARM-sunxi-sunxi_cpu0_hotplug_support_set-is-not-supported-on-A8"
    # # byName."firmware-scpi-Add-support-for-sending-a-SCPI_CMD_SET_SYS_PWR_ST"
    # # byName."ARM-sunxi-Use-SCPI-to-send-suspend-message-to-SCP-on-A83T"
    # # byName."gnss-ubx-Send-soft-powerdown-message-on-suspend"
    # # byName."clk-sunxi-ng-Export-CLK_DRAM-for-devfreq"
    # # byName."ARM-dts-sun8i-a83t-Add-MBUS-node"
    # # byName."clk-sunxi-ng-Set-maximum-P-and-M-factors-to-1-for-H3-pll-cpux-c"
    # # byName."clk-sunxi-ng-Don-t-use-CPU-PLL-gating-and-CPUX-reparenting-to-H"
    # # byName."ARM-dts-sun8i-h3-Use-my-own-more-aggressive-OPPs-on-H3"
    # # byName."arm64-dts-sun50i-h5-Use-my-own-more-aggressive-OPPs-on-H5"
    # # byName."ARM-dts-sun8i-h3-orange-pi-pc-Increase-max-CPUX-voltage-to-1.4V"
    # # byName."ARM-dts-sun8i-a83t-Improve-CPU-OPP-tables-go-up-to-1.8GHz"
    # # byName."cpufreq-sun50i-Show-detected-CPU-bin-for-easier-debugging"
    # # byName."net-stmmac-sun8i-Use-devm_regulator_get-for-PHY-regulator"
    # # byName."net-stmmac-sun8i-Rename-PHY-regulator-variable-to-regulator_phy"
    # # byName."net-stmmac-sun8i-Add-support-for-enabling-a-regulator-for-PHY-I"
    # # byName."arm64-dts-allwinner-orange-pi-3-Enable-ethernet"
    # # byName."input-cyttsp4-De-obfuscate-platform-data-for-keys"
    # # byName."input-cyttsp4-Remove-useless-indirection-with-driver-platform-d"
    # # byName."input-cyttsp4-Remove-unused-enable_vkeys"
    # # byName."input-cyttsp4-De-obfuscate-MT-signals-setup-platform-data"
    # # byName."input-cyttsp4-Clear-the-ids-buffer-in-a-saner-way"
    # # byName."input-cyttsp4-ENOSYS-error-is-ok-when-powering-up"
    # # byName."input-cyttsp4-Faster-recovery-from-failed-wakeup-HACK"
    # # byName."input-cyttsp4-Use-i2c-spi-names-directly-in-the-driver"
    # # byName."input-cyttsp4-Port-the-driver-to-use-device-properties"
    # # byName."input-cyttsp4-Restart-on-wakeup-wakeup-by-I2C-read-doesn-t-work"
    # # byName."input-cyttsp4-Fix-warnings"
    # # byName."input-cyttsp4-Make-the-driver-not-hog-the-system-s-workqueue"
    # # byName."input-cyttsp4-Fix-probe-oops"
    # # byName."video-fbdev-eInk-display-driver-for-A13-based-PocketBooks"
    # # byName."regulator-Add-simple-driver-for-enabling-a-regulator-from-users"
    # # byName."regulator-tp65185x-Add-tp65185x-eInk-panel-regulator-driver"
    # # byName."regulator-tp65185-Add-hwmon-device-for-reading-temperature"
    # # byName."iio-adc-sun4i-gpadc-iio-Allow-to-use-sun5i-a13-gpadc-iio-from-D"
    # # byName."mtd-spi-nor-Add-vdd-regulator-support"
    # # byName."ARM-dts-sun5i-Add-soc-handle"
    # # byName."ARM-dts-sun5i-Add-PocketBook-Touch-Lux-3-display-ctp-support"
    # # byName."ARM-dts-sun5i-a13-pocketbook-touch-lux-3-Add-RTC-clock-cells"
    byName."arm64-dts-sun50i-a64-pinephone-Add-front-back-cameras"
    # "Add Type C support" actually adds a *bunch* of stuff to the device tree not immediately relevant to USB-C.
    # notably, it defines several of the voltage regulators, one of which is required to power the modem.
    byName."arm64-dts-sun50i-a64-pinephone-Add-Type-C-support-for-all-PP-va"
    patches.sane.vbat-bb-always-on  #< slight tweak to `Add-Type-C-support...` to ensure power to the modem
    (if withModemPower then byName."arm64-dts-sun50i-a64-pinephone-Add-modem-power-manager" else nullPatch)
    # byName."arm64-dts-sun50i-a64-pinephone-Fix-BH-modem-manager-behavior"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-detailed-OCV-to-capactiy-con"
    # byName."arm64-dts-sun50i-a64-pinephone-Shorten-post-power-on-delay-on-m"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-mount-matrix-for-acceleromet"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-support-for-Bluetooth-audio"
    # byName."arm64-dts-sun50i-a64-pinephone-Enable-internal-HMIC-bias"
    byName."arm64-dts-sun50i-a64-pinephone-Add-support-for-modem-audio"  #< required for "arm64-dts-sun50i-a64-pinephone-Use-newer-jack-detection-impleme" to apply
    # byName."arm64-dts-sun50i-a64-pinephone-Bump-I2C-frequency-to-400kHz"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-interrupt-pin-for-WiFi"
    # byName."arm64-dts-sun50i-a64-pinephone-Power-off-the-touch-controller-i"
    # byName."arm64-dts-sun50i-a64-pinephone-Don-t-make-lradc-keys-a-wakeup-s"
    # byName."arm64-dts-sun50i-a64-pinephone-Set-minimum-backlight-duty-cycle"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-supply-for-i2c-bus-to-anx768"
    # byName."arm64-dts-sun50i-a64-pinephone-Workaround-broken-HDMI-HPD-signa"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-AF8133J-to-PinePhone"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-mount-matrix-for-PinePhone-m"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-support-for-Pinephone-keyboa"
    # byName."arm64-dts-sun50i-a64-pinephone-Enable-Pinephone-Keyboard-power-"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-support-for-Pinephone-1.2-be"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-power-supply-to-stk3311"
    # byName."arm64-dts-sun50i-a64-pinephone-Add-reboot-mode-driver"

    # some or all of these audio patches are required for speaker audio:
    # TODO: mainline sun50i-a64-pinephone.dtsi defines headphone jack, internal earpiece *and* internal speaker;
    #       these patches shouldn't actually be necessary?? might just need to (un-)fix alsa-ucm-conf, or init them with eg25-manager
    byName."arm64-dts-sun50i-a64-pinephone-Use-newer-jack-detection-impleme"
    byName."arm64-dts-sun50-a64-pinephone-Define-jack-pins-in-DT"
    byName."dt-bindings-sound-Add-jack-type-property-to-sun8i-a33-codec"
    byName."ASoC-sun8i-codec-Allow-the-jack-type-to-be-set-via-device-tree"
    # byName."ASoC-sun8i-codec-define-button-keycodes"
    # byName."ASoC-sun8i-codec-Add-debug-output-for-jack-detection"
    byName."ASoC-sun8i-codec-Set-jack_type-from-DT-in-probe"  #< without this, audio is permanently routed to speakers and doesn't switch to headphones
    byName."ASoC-simple-card-Allow-to-define-pins-for-aux-jack-devices"  #< without this, audio out to speakers does not work.
    # # some or all of these audio patches are relevant not (just) to the modem audio path,
    # # but are required for headphone and speaker output.
    # byName."clk-sunxi-ng-a64-Increase-PLL_AUDIO-base-frequency"
    # byName."dt-bindings-mfd-Add-codec-related-properties-to-AC100-PMIC"
    # byName."sound-soc-ac100-codec-Support-analog-part-of-X-Powers-AC100-cod"
    # byName."sound-soc-sun8i-codec-Add-support-for-digital-part-of-the-AC100"
    byName."ASoC-ec25-New-codec-driver-for-the-EC25-modem"  #< required for speaker audio (which works even with modem powered off)

    # # byName."ASOC-sun9i-hdmi-audio-Initial-implementation"  #< linux 6.11: `error: initialization of 'void (*)(struct platform_device *)' from incompatible pointer type 'int (*)(struct platform_device *)'`
    # # byName."ARM-dts-sunxi-h3-h5-Add-hdmi-sound-card"
    # # byName."ARM-dts-sun8i-h3-Enable-hdmi-sound-card-on-boards-with-hdmi"
    # # byName."ARM-dts-sun8i-h2-plus-bananapi-m2-zero-Enable-HDMI-audio"
    # # byName."ARM-dts-sun8i-a83t-Add-hdmi-sound-card"
    # # byName."ARM-dts-sun8i-a83t-Enable-hdmi-sound-card-on-boards-with-hdmi"
    # # byName."ARM-dts-sun8i-r40-Add-hdmi-sound-card"
    # # byName."ARM-dts-sun8i-r40-bananapi-m2-ultra-Enable-HDMI-audio"
    # # byName."ARM-dts-sun8i-v40-bananapi-m2-berry-Enable-HDMI-audio"
    # # byName."arm64-dts-allwinner-h6-Add-hdmi-sound-card"
    # # byName."arm64-dts-allwinner-h6-Enable-hdmi-sound-card-on-boards-with-hd"
    # this patch is necessary to ensure the `sound_hdmi` device tree node exists,
    # as required by `Add-Type-C-support`...
    byName."arm64-dts-allwinner-a64-Add-hdmi-sound-card"
    # byName."arm64-dts-allwinner-a64-Enable-hdmi-sound-card-on-boards-with-h"
    # # byName."arm64-dts-allwinner-h5-Enable-hdmi-sound-card-on-boards-with-hd"
    # # byName."arm64-dts-sun50i-a64-Set-fifo-size-for-uarts"
    # # byName."ARM-dts-sun8i-a83t-Set-fifo-size-for-uarts"
    # # byName."Mark-some-slow-drivers-for-async-probe-with-PROBE_PREFER_ASYNCH"
    # # byName."arm64-xor-Select-32regs-without-benchmark-to-speed-up-boot"
    # # byName."clk-Implement-protected-clocks-for-all-OF-clock-providers"
    # # byName."Revert-clk-qcom-Support-protected-clocks-property"
    # # byName."ARM-dts-sunxi-a83t-Protect-SCP-clocks"
    # # byName."ARM-dts-sunxi-h3-h5-Protect-SCP-clocks"
    # # byName."arm64-dts-allwinner-a64-Protect-SCP-clocks"
    # # byName."arm64-dts-allwinner-h6-Protect-SCP-clocks"
    # byName."bus-sunxi-rsb-Always-check-register-address-validity"
    # byName."firmware-arm_scpi-Support-unidirectional-mailbox-channels"
    # # byName."ARM-dts-sunxi-a83t-Add-SCPI-protocol"
    # # byName."ARM-dts-sunxi-h3-h5-Add-SCPI-protocol"
    # # byName."arm64-dts-allwinner-a64-Add-SCPI-protocol"
    # # byName."arm64-dts-allwinner-h6-Add-SCPI-protocol"
    # # byName."ARM-dts-sun8i-a83t-tbs-a711-Give-Linux-more-privileges-over-SCP"
    # # byName."rtc-sun6i-Allow-RTC-wakeup-after-shutdown"
    (if withModemPower then byName."misc-modem-power-Power-manager-for-modems" else nullPatch)
    # # byName."ARM-dts-sun8i-a83t-Add-missing-GPU-trip-point"
    # # byName."arm64-dts-sun50i-h5-Add-missing-GPU-trip-point"
    # byName."arm64-dts-sun50i-a64-Add-missing-trip-points-for-GPU"
    # byName."arm64-dts-allwinner-a64-Fix-LRADC-compatible"
    # byName."ASoC-codec-es8316-DAC-Soft-Ramp-Rate-is-just-a-2-bit-control"
    # # byName."spi-rockchip-Fix-runtime-PM-and-other-issues"
    # # byName."spi-fixes"
    # byName."media-cedrus-Fix-failure-to-clean-up-hardware-on-probe-failure"
    # # byName."ASoC-rockchip-Fix-doubling-of-playback-speed-after-system-sleep"
    # byName."usb-musb-sunxi-Avoid-enabling-host-side-code-on-SoCs-where-it-s"
    # byName."arm64-dts-allwinner-Enforce-consistent-MMC-numbering"
    # byName."ARM-dts-sunxi-Add-aliases-for-MMC"
    # # byName."drm-rockchip-Fix-panic-on-reboot-when-DRM-device-fails-to-bind"
    # byName."usb-gadget-Fix-dangling-pointer-in-netdev-private-data"  #< required for "Fix-for-usb-gadget-on-PP" to apply
    # byName."Fix-for-usb-gadget-on-PP"
    # # byName."mmc-dw-mmc-rockchip-fix-sdmmc-after-soft-reboot"
    # byName."Revert-drm-sun4i-lvds-Invert-the-LVDS-polarity"
    # byName."of-property-fw_devlink-Support-allwinner-sram-links"
    # # byName."arm64-dts-rockchip-rk356x-Fix-PCIe-register-map-and-ranges"
    # # byName."Fix-intptr_t-typedef"
    # # byName."mmc-sunxi-mmc-Remove-runtime-PM"
    # # byName."pci-Workaround-ITS-timeouts-on-poweroff-reboot-on-Orange-Pi-5-P"
    # # byName."usb-serial-option-add-reset_resume-callback-for-WWAN-devices"
    # # byName."media-rkisp1-Adapt-to-different-SoCs-having-different-size-limi"
    # # byName."media-ov5648-Fix-call-to-pm_runtime_set_suspended"
    # # byName."drm-rockchip-dw-mipi-dsi-rockchip-Fix-ISP1-PHY-initialization"
    # # byName."drm-rockchip-dw-mipi-dsi-rockchip-Restore-DPHY-config-on-resume"
    # # byName."bluetooth-h5-Don-t-re-initialize-rtl8723cs-on-resume"
    # # byName."drm-sun4i-Unify-sun8i_-_layer-structs"
    # # byName."drm-sun4i-Add-more-parameters-to-sunxi_engine-commit-callback"
    # # byName."drm-sun4i-Fix-layer-zpos-change-atomic-modesetting"
    # # byName."drm-sun4i-drm-Change-update_bits-to-write"
    # # byName."drm-sun4i-Mark-one-of-the-UI-planes-as-a-cursor-one"
    # # byName."drm-sun4i-Implement-gamma-correction"
    # # byName."drm-panel-st7703-Fix-xbd599-timings-to-make-refresh-rate-exactl"
    # # byName."drm-sun4i-Support-taking-over-display-pipeline-state-from-p-boo"
    # # byName."video-pwm_bl-Allow-to-change-lth_brightness-via-sysfs"
    # # byName."clk-sunxi-ng-sun50i-a64-Switch-parent-of-MIPI-DSI-to-periph0-1x"
    # byName."drm-sun4i-tcon-Support-keeping-dclk-rate-upon-ancestor-clock-ch"
    # byName."phy-allwinner-sun4i-usb-Add-support-for-usb_role_switch"
    # byName."regulator-axp20x-Add-support-for-vin-supply-for-drivevbus"
    # # byName."regulator-axp20x-Turn-N_VBUSEN-to-input-on-x-powers-sense-vbus-"
    # byName."drm-bridge-dw-hdmi-Allow-to-accept-HPD-status-from-other-driver"
    # byName."drm-bridge-dw-hdmi-Report-HDMI-hotplug-events"
    # byName."usb-typec-anx7688-Add-driver-for-ANX7688-USB-C-HDMI-bridge"
    # byName."usb-typec-anx7688-Port-to-Linux-6.9"
    # byName."usb-typec-anx7688-Port-to-Linux-6.10"
    # byName."dt-bindings-axp20x-adc-allow-to-use-TS-pin-as-GPADC"
    # byName."iio-adc-axp20x_adc-allow-to-set-TS-pin-to-GPADC-mode"
    # byName."power-axp20x_battery-Allow-to-set-target-voltage-to-4.35V"
    # byName."power-supply-axp20x_battery-Add-support-for-reporting-OCV"
    # byName."regulator-axp20x-Enable-over-temperature-protection-and-16s-res"
    # byName."power-supply-axp20x_battery-Setup-thermal-regulation-experiment"
    # byName."power-supply-axp20x_battery-Fix-charging-done-detection"
    # byName."mfd-axp20x-Add-battery-IRQ-resources"
    # byName."power-supply-axp20x_battery-Send-uevents-for-status-changes"
    # byName."power-supply-axp20x_battery-Monitor-battery-health"
    # byName."power-supply-axp20x-usb-power-Change-Vbus-hold-voltage-to-4.5V"
    # byName."power-axp803-Add-interrupts-for-low-battery-power-condition"
    # byName."power-supply-axp20x-battery-Support-POWER_SUPPLY_PROP_CHARGE_BE"
    # byName."power-supply-axp20x-battery-Enable-poweron-by-RTC-alarm"
    # byName."power-supply-axp20x-battery-Add-support-for-POWER_SUPPLY_PROP_E"
    # byName."power-supply-Add-support-for-USB_BC_ENABLED-and-USB_DCP_INPUT_C"
    # byName."power-supply-axp20x-usb-power-Add-missing-interrupts"
    # # byName."sunxi-Use-dev_err_probe-to-handle-EPROBE_DEFER-errors"
    # # byName."thermal-sun8i-Be-loud-when-probe-fails"
    # # byName."i2c-mv64xxx-Don-t-make-a-fuss-when-pinctrl-recovery-state-is-no"
    # # byName."iio-st_sensors-Don-t-report-error-when-the-device-is-not-presen"
    # # byName."opp-core-Avoid-confusing-error-when-no-regulator-is-defined-in-"
    # # byName."rtc-Print-which-error-caused-RTC-read-failure"
    # # byName."arm64-dts-allwinner-a64-pinetab-add-front-camera"
    # # byName."arm64-allwinner-dts-a64-enable-K101-IM2BYL02-panel-for-PineTab"
    # # byName."arm64-dts-sun50i-a64-pinetab-Name-sound-card-PineTab"
    # # byName."arm64-dts-sun50i-a64-pinetab-Add-accelerometer"
    # # byName."arm64-dts-sun50i-a64-pinetab-enable-RTL8723CS-bluetooth"
    # byName."usb-typec-fusb302-Slightly-increase-wait-time-for-BC1.2-result"
    # byName."usb-typec-fusb302-Set-the-current-before-enabling-pullups"
    # byName."usb-typec-fusb302-Extend-debugging-interface-with-driver-state-"
    # byName."usb-typec-fusb302-Retry-reading-of-CC-pins-status-if-activity-i"
    # byName."usb-typec-fusb302-More-useful-of-logging-status-on-interrupt"
    # byName."usb-typec-fusb302-Update-VBUS-state-even-if-VBUS-interrupt-is-n"
    # byName."usb-typec-fusb302-Add-OF-extcon-support"
    # byName."usb-typec-fusb302-Fix-register-definitions"
    # byName."usb-typec-fusb302-Clear-interrupts-before-we-start-toggling"
    # # byName."usb-typec-typec-extcon-Add-typec-extcon-bridge-driver"  #< one of these causes a build error in linux 6.11
    # # byName."usb-typec-typec-extcon-Enable-debugging-for-now"
    # # byName."usb-typec-typec-extcon-Allow-to-force-reset-on-each-mux-change"
    # byName."Revert-usb-typec-tcpm-unregister-existing-source-caps-before-re"
    # byName."usb-typec-altmodes-displayport-Respect-DP_CAP_RECEPTACLE-bit"
    # byName."usb-typec-tcpm-Unregister-altmodes-before-registering-new-ones"
    # byName."usb-typec-tcpm-Fix-PD-devices-capabilities-registration"
    # # byName."usb-typec-tcpm-Improve-logs"
    # # byName."Make-microbuttons-on-Orange-Pi-PC-and-PC-2-work-as-power-off-bu"
    # # byName."Add-support-for-my-private-Sapomat-device"
    # # byName."ARM-dts-sun8i-h3-orange-pi-one-Enable-all-gpio-header-UARTs"
    # # byName."mtd-spi-nor-Add-Alliance-memory-support"
    # # byName."Add-README.md-with-information-and-u-boot-patches"
    # # byName."Defconfigs-for-all-my-devices"
    # # byName."Update-defconfigs"
  ]) ++ [
    # {
    #   name = "fix-compilation-specific-to-megi";
    #   patch = null;
    #   structuredExtraConfig = with lib.kernel; {
    #     ### BUILD FIXES, NOT SPECIFIC TO MY PREFERENCES
    #     #
    #     # disabling the sun5i_eink driver avoids this compilation error:
    #     # CC [M]  drivers/video/fbdev/sun5i-eink-neon.o
    #     # aarch64-unknown-linux-gnu-gcc: error: unrecognized command line option '-mfloat-abi=softfp'
    #     # aarch64-unknown-linux-gnu-gcc: error: unrecognized command line option '-mfpu=neon'
    #     # make[3]: *** [../scripts/Makefile.build:289: drivers/video/fbdev/sun5i-eink-neon.o] Error 1
    #     FB_SUN5I_EINK = no;
    #     BES2600 = no;  # fails to compile (implicit declaration of function 'ieee80211_tx_status'; did you mean 'ieee80211_tx_status_ni')

    #     # SUN8I_DE2_CCU = lib.mkForce module;  #< want:y, got:M
    #   };
    # }
    {
      # this could be enabled for *all* systems, but i'm not sure i really want that.
      name = "quality-of-life";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        # optimize for faster builds (measured 12m00s -> 10m45s)
        # see <repo:kernel.org/linux:Documentation/admin-guide/quickly-build-trimmed-linux.rst>
        # note that several options can re-enable DEBUG_KERNEL (such as DEBUG_LIST)
        # DEBUG_KERNEL = lib.mkForce no;  # option group which seems to just gate the other DEBUG_ opts?
        DEBUG_INFO = lib.mkForce no;  # for gdb debugging (does it impact kernel stacktraces, too?)
        # DEBUG_INFO_NONE = lib.mkForce no;
        DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = lib.mkForce no;
        # DEBUG_LIST = lib.mkForce no;
        # DEBUG_MISC = lib.mkForce no;
        # DEBUG_FS = no;

        DEBUG_INFO_BTF = lib.mkForce no;  # BPF debug symbols. rec by <https://nixos.wiki/wiki/Linux_kernel#Too_high_ram_usage>
        # SCHED_DEBUG = lib.mkForce no;  # determines /sys/kernel/debug/sched
        SUNRPC_DEBUG = lib.mkForce no;
        # shave 500ms off Pinephone boot time (dmesg | grep raid6)
        # - by default raid6 (on behalf of btrfs) will compute the fastest algorithms at boot.
        # - AFAICT, this only comes into effect if using raid (i don't).
        # - in any case, on moby, the fastest benchmark happens to be the default anyway.
        # - on lappy/servo/desko, the default is about 3% slower than the fastest. but they compute this in < 100ms.
        RAID6_PQ_BENCHMARK = lib.mkForce no;
      };
    }
    {
      name = "fix-no-display";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        ### RUNTIME FIXES AFTER <https://github.com/NixOS/nixpkgs/pull/298332>
        # pmOS kernel config is in pmaports repo:
        # - CONFIG_FB_SIMPLE=y
        # - CONFIG_DRM_SIMPLEDRM is unset
        # - CONFIG_SYSFB_SIMPLEFB is not referenced
        # these config values are speculative: could probably be made smaller
        FB_SIMPLE = lib.mkForce yes;
        DRM_SIMPLEDRM = lib.mkForce no;  #< conflicts with FB_SIMPLE
        # SYSFB_SIMPLEFB = lib.mkForce no;

        DRM = yes;
        # downgrade these from "yes" to "module", to match previous config.
        # DRM = lib.mkForce module;
      };
    }
  ] ++ lib.optionals (withMegousPatches && withModemPower) [
    {
      name = "enable-megi-modem-power";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        # enable /sys/class/modem-power, a thing specific to Megi's kernel/patches
        MODEM_POWER = module;
      };
    }
  # ] ++ lib.optionals withNixpkgsConfig [
  #   {
  #     name = "nixpkgs-config";
  #     patch = null;
  #     structuredExtraConfig = linux_latest.commonStructuredConfig;
  #   }
  ] ++ lib.optionals usePmosConfig [
    {
      name = "postmarketos-config";
      patch = null;
      structuredExtraConfig = builtins.removeAttrs
        (sane-kernel-tools.parseDefconfigStructuredNonempty linux-postmarketos-allwinner.defconfigStr)
        ([
          # remove attrs which nixpkgs wants to set for itself, only because the kernel config options are so fucked that i can't figure out how to override things without breaking eval
          # "RAID6_PQ_BENCHMARK"

          # these options have changed since the version which pmos ships? or pmos just ships invalid values
          # "repeated questions"
          "NETFILTER_XT_TARGET_TPROXY"
          "NETFILTER_XT_MATCH_HASHLIMIT"
          "NETFILTER_XT_MATCH_SOCKET"
          "IP_NF_MATCH_RPFILTER"
          "CFG80211"
          "MAC80211"
          # "DRM_SUN4I"
          # "DRM_SUN6I_DSI"
          # "DRM_SUN8I_DW_HDMI"
          # "DRM_SUN8I_MIXER"
          "DRM_PANEL_FEIXIN_K101_IM2BA02"
          "DRM_PANEL_FEIYANG_FY07024DI26A30D"
          "DRM_PANEL_ILITEK_ILI9881C"
          "DRM_PANEL_SITRONIX_ST7703"
          "DRM_PANEL_SIMPLE"  #< nixpkgs:m, pmos:y
        ] ++ lib.optionals withNixpkgsConfig [
          "BINFMT_MISC"
          # "DEFAULT_MMAP_MIN_ADDR"
          "IP_NF_TARGET_REDIRECT"
          "IP_PNP"
          "LOGO"
          "NLS_CODEPAGE_437"  #< nixpkgs:m, pmos:y
          "NLS_DEFAULT"  #< nixpkgs:m, pmos:y
          "NLS_ISO8859_1"  #< nixpkgs:m, pmos:y
          "NR_CPUS"

          "CMA_SIZE_MBYTES"
          "DEFAULT_MMAP_MIN_ADDR"
          "PREEMPT"
          "STANDALONE"
          "TRANSPARENT_HUGEPAGE_ALWAYS"
          "UEVENT_HELPER"
          "USB_SERIAL"
          "ZSMALLOC"

          # "DRM_LIMA"
          # "DRM_PANFROST"

          # these options don't break build, but are nonsensical
          "BASE_SMALL"
          "BASE_FULL"
          "CC_VERSION_TEXT"
          "GCC_VERSION"
        ] ++ lib.optionals (withNixpkgsConfig && withFullConfig) [
          # "STMMAC_ETH"  #< autoModules:m, pmos:y
          # "STMMAC_PLATFORM"  #< autoModules:m, pmos:y
          # "DWMAC_GENERIC"  #< autoModules:m, pmos:y
          # "DWMAC_SUNXI"  #< autoModules:m, pmos:y
          # "DWMAC_SUN8I"  #< autoModules:m, pmos:y
          "BLK_DEV_DM"  #< autoModules:m, pmos:y
          "VFIO"  #< autoModules:m, pmos:y
        ]
      );
    }
  ] ++ lib.optionals (!usePmosConfig) [
    {
      name = "enable options for Pinephone";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        # VIDEO_SUNXI defaults to `n` since the driver is in staging (as of 2024-09-18)
        VIDEO_SUNXI = yes;
        # VIDEO_SUNXI_CEDRUS = module;  #< implied by VIDEO_SUNXI

        BACKLIGHT_CLASS_DEVICE = yes;  #< required for display initialization (adding "backlight" to initrd does not fix display)
        # AXP20X_ADC = yes;  #< required for display initialization (or add "axp20x_adc" to `boot.initrd.availableKernelModules`)

        # XXX(2024-09-18): megapixels(-next) fails to open the camera without this option:
        ARM64_VA_BITS_48 = yes;  #< 48 (not 52) bits for virtual addresses. the other bit widths (ARM64_VA*, ARM64_PA_*, PGTABLE_LEVELS) are then derived/implied same as pmos config


        # #vvv aside from SUN50I_IOMMU, this is just upgrading modules to `y`
        # DMA_SUN6I = yes;
        # SUN50I_IOMMU = yes;
        # VIDEOBUF2_CORE = yes;
        # VIDEOBUF2_V4L2 = yes;
        # VIDEOBUF2_MEMOPS = yes;
        # VIDEOBUF2_DMA_CONTIG = yes;

        # MFD_SUN6I_PRCM = yes;

        # allow kernel modules to read the device tree at runtime
        # OF_RESOLVE = yes;
        # OF_OVERLAY = yes;

        # THERMAL_STATISTICS = yes;
        # THERMAL_GOV_FAIR_SHARE = yes;
        # THERMAL_GOV_BANG_BANG = yes;
        # USB_ANNOUNCE_NEW_DEVICES = yes;
        # LEDS_BRIGHTNESS_HW_CHANGED = yes;
        # SERIAL_8250_NR_UARTS = freeform "4";
        # RCU_CPU_STALL_TIMEOUT = freeform "60";
        # INPUT_JOYSTICK = yes;
        # RT2800USB_RT3573 = yes;
        # NETFILTER_XTABLES_COMPAT = yes;
        # ARM64_ERRATUM_2441007 = yes;
        # ARM64_ERRATUM_1286807 = yes;
        # ARM64_ERRATUM_1542419 = yes;
        # ARM64_ERRATUM_2441009 = yes;
        # BT_BNEP_MC_FILTER = yes;
        # BT_BNEP_PROTO_FILTER = yes;
        # BT_LE = yes;
        # BT_LE_L2CAP_ECRED = yes;
        # BT_6LOWPAN = module;
        # BT_HCIUART_3WIRE = yes;
        # BT_HCIUART_RTL = yes;

        # CONTEXT_TRACKING_USER = no;
        # TICK_CPU_ACCOUNTING = yes;
        # VIRT_CPU_ACCOUNTING = no;
        # VIRT_CPU_ACCOUNTING_GEN = no;
        # RCU_EXPERT = yes;
        # RCU_FANOUT = freeform "64";
        # RCU_FANOUT_LEAF = freeform "16";

        # some or all of this is required for `megapixels`(-next) to operate the camera (possibly CMA/DMA related?)
        # ARM64_LPA2 = yes;
        # ARM64_VA_BITS_48 = yes;
        # ARM64_VA_BITS = freeform "48";
        # ARM64_PA_BITS_48 = yes;
        # ARM64_PA_BITS = freeform "48";
        # ARCH_MMAP_RND_BITS_MAX = freeform "33";
        # PGTABLE_LEVELS = freeform "4";

        # PM_AUTOSLEEP = yes;
        # CPU_IDLE_GOV_LADDER = no;
        # ZSMALLOC_STAT = yes;
        # ZRAM_TRACK_ENTRY_ACTIME = yes;
        # ZRAM_MEMORY_TRACKING = yes;
        # HW_RANDOM_TPM = no;
        # USB_CONFIGFS_F_TCM = yes;
        # VALIDATE_FS_PARSER = yes;

        # CMDLINE_FROM_BOOTLOADER = yes;

        # pmOS specifies these as 'y', while nixpkgs/autoModules would only make them 'm': change them back to 'y'
        # SUN4I_EMAC = yes;
        # STMMAC_ETH = yes;
        # STMMAC_PLATFORM = yes;
        # DWMAC_GENERIC = yes;
        # DWMAC_SUNXI = yes;
        # DWMAC_SUN8I = yes;
        # MDIO_SUN4I = yes;
        # PCS_XPCS = yes;

        # IP5XXX_POWER = yes;  #< TODO: almost certainly not used in Pinephone
        # TOUCHSCREEN_GOODIX = yes;

        # some or all of these are required for display initialization.
        # INPUT_AXP20X_PEK = yes;
        # CHARGER_AXP20X = yes;
        # BATTERY_AXP20X = yes;
        # AXP20X_ADC = yes;
        # AXP20X_POWER = yes;
        # REGULATOR_VCTRL = yes;

        # RC_MAP = yes;
        # IR_SUNXI = yes;
        # CEC_CORE = yes;
        # DVB_CORE = yes;

        # MEDIA_SUPPORT = yes;  #< removing this forces V4L2 stuff to be degraded to module
        # VIDEO_DEV = yes;
        # V4L2_MEM2MEM_DEV = yes;
        # # # V4L2_FLASH_LED_CLASS = yes;
        # V4L2_FWNODE = yes;
        # V4L2_ASYNC = yes;
        # VIDEO_MEM2MEM_DEINTERLACE = yes;
        # VIDEO_SUN6I_CSI = yes;
        # VIDEO_SUN8I_DEINTERLACE = yes;
        # VIDEO_SUN8I_ROTATE = yes;
        # VIDEOBUF2_CORE = yes;
        # VIDEOBUF2_V4L2 = yes;
        # VIDEOBUF2_MEMOPS = yes;
        # VIDEOBUF2_DMA_CONTIG = yes;
        # VIDEO_SUNXI_CEDRUS = yes;

        # DRM_DISPLAY_HELPER = yes;
        # DRM_GEM_DMA_HELPER = yes;
        # DRM_GEM_SHMEM_HELPER = yes;
        # DRM_SCHED = yes;
        # DRM_SUN4I = yes;
        # DRM_SUN6I_DSI = yes;
        # DRM_SUN8I_DW_HDMI = yes;
        # DRM_SUN8I_MIXER = yes;
        # DRM_SUN8I_TCON_TOP = yes;
        # DRM_DW_HDMI = yes;
        # DRM_LIMA = yes;
        # DRM_PANFROST = yes;

        # BACKLIGHT_CLASS_DEVICE = yes;
        # LCD_CLASS_DEVICE = yes;
        # BACKLIGHT_PWM = yes;
        # DMA_SUN6I = yes;
        # PWM_SUN4I = yes;
        # PHY_SUN6I_MIPI_DPHY = yes;

        # USB stuff ellided...
        # PHY_SUN50I_USB3 = yes;
        # PHY_QCOM_USB_HS = yes;

        # LEDS_CLASS_FLASH = yes;
        # # LEDS_SGM3140 = yes;
        # LEDS_TRIGGER_PATTERN = yes;

        # # DRM = lib.mkForce yes;  #< upgrade from module to builtin
        # DEFAULT_MMAP_MIN_ADDR = lib.mkForce (freeform "4096");
        # STANDALONE = lib.mkForce no;
        # PREEMPT = lib.mkForce yes;
        # TRANSPARENT_HUGEPAGE_ALWAYS = lib.mkForce yes;
        # ZSMALLOC = lib.mkForce no;
        # UEVENT_HELPER = lib.mkForce yes;
        # USB_SERIAL = lib.mkForce module;
        # ZSWAP = lib.mkForce no;
        # # ZPOOL = lib.mkForce no;
      };
    }
    # {
    #   name = "enable options for libcamera development";
    #   patch = null;
    #   structuredExtraConfig = with lib.kernel; {
    #     # borrowed from postmarketOS, "to enable libcamera development"
    #     # pmaports commit f18c7210ab
    #     # DMABUF_HEAPS = yes;
    #     # DMABUF_HEAPS_CMA = yes;
    #     # borrowed from postmarketOS, speculatively, as i debug megapixels camera
    #     # CMA_AREAS = "CMA allows to create CMA areas for particular purpose, mainly, used as device private area."
    #     #             "If unsure, leave the default value "8" in UMA and "20" in NUMA."
    #     # - pinephone in mainline linux, postmarketOS, defaults to 7
    #     # - nixos defaults to ... 19?
    #     # CMA_AREAS = freeform "7";
    #     # DRM_ACCEL = lib.mkForce no;

    #     # CMA_SIZE_MBYTES = lib.mkForce (freeform "256");  #< also available at boot time via `cma=256M` CLI

    #     # see: <https://gitlab.com/postmarketOS/pmaports/-/merge_requests/5541/>
    #     # UDMABUF = yes;  #< not needed (nixos default)
    # }
  ] ++ lib.optionals (!withFullConfig) [
    {
      name = "enable-rtw88-wifi-drivers";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        # default nixpkgs/pmos config enables RTW88, but not RTW88_8723CS.
        # but the pinephone uses a 8723BS/8723CS chipset, so enable these
        # and anything else that could possibly be needed, since these things are tangled.
        # TODO: reduce this, this is surely more than i actually need
        # RTL8187_LEDS=y
        # RTLWIFI_DEBUG=y
        # RTL8180 = module;
        # RTL8187 = module;
        # RTL8188EE = module;
        # RTL8192CE = module;
        # RTL8192CU = module;
        # RTL8192C_COMMON = module;
        # RTL8192DE = module;
        # RTL8192D_COMMON = module;
        # RTL8192EE = module;
        # RTL8192SE = module;
        # RTL8723AE = module;
        # RTL8723BE = module;
        # RTL8723_COMMON = module;
        # RTL8821AE = module;
        # RTL8XXXU = module;
        # RTLBTCOEXIST = module;
        # RTLWIFI = module;
        # RTLWIFI_PCI = module;
        # RTLWIFI_USB = module;
        RTW88_8703B = module;
        RTW88_8723CS = module;
        RTW88_8723D = module;
        RTW88_8723DE = module;
        RTW88_8723DS = module;
        RTW88_8723DU = module;
        RTW88_8723X = module;
        RTW88_8821C = module;
        RTW88_8821CE = module;
        RTW88_8821CS = module;
        RTW88_8821CU = module;
        RTW88_8822BS = module;
        RTW88_8822BU = module;
        RTW88_8822CS = module;
        RTW88_8822CU = module;
        RTW88_SDIO = module;
        RTW88_USB = module;
      };
    }
  ];

  passthru = {
    inherit patches;
  };
}
