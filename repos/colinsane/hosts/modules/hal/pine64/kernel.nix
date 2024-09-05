{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.pine64;
in
{
  config = lib.mkIf cfg.enable {
    # kernel compat (2024/08/31: b9cd911c)
    # - linux-postmarketos-allwinner: it's my daily driver
    # - linux_latest, i.e. mainline 6.10.7: WiFi works; modem works; charging requires ANX7688 patches; display requires CONFIG_FB_SIMPLE=y
    #   - wifi is spotty
    # - linux_testing, i.e. 6.11.0-rc5: WiFi works; charging & display works with the 6.10 patches; megi's modem-power patch doesn't apply
    #   - wifi feels no better than 6.10
    # kernel compatibility (2024/05/22: 03dab630)
    # - linux-megous: boots to ssh, desktop
    #   - camera apps: megapixels (no cameras found), snapshot (no cameras found)
    # - linux-postmarketos-allwinner: boots to ssh. desktop ONLY if "anx7688" is in the initrd.availableKernelModules.
    #   - camera apps: megapixels (both rear and front cameras work), `cam -l` (finds only the rear camera), snapshot (no cameras found)
    # - linux-megous.override { withMegiPinephoneConfig = true; }: NO SSH, NO SIGNS OF LIFE
    # - linux-megous.override { withFullConfig = false; }: boots to ssh, no desktop
    #
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-postmarketos-allwinner.override {
    #   withModemPower = true;
    # });
    #
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-megous;
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-megous.override {
    #   withFullConfig = false;
    # });
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-megous.override {
    #   withMegiPinephoneConfig = true;  #< N.B.: does not boot as of 2024/05/22!
    # });
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-manjaro;
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_testing;

    # megi's patches apply cleanly, but fails to compile without tweaking config (e.g. CONFIG_FB_SUN5I_EINK=n)
    # boot.kernelPatches = pkgs.armbian-build.patches.megous.series;

    boot.kernelPatches = with pkgs.armbian-build.patches.megous; [
      # ANX7688 USB-C driver; required for display initialization and for battery charging
      # byName."usb-typec-anx7688-Add-driver-for-ANX7688-USB-C-HDMI-bridge"
      # byName."usb-typec-anx7688-Port-to-Linux-6.9"
      # byName."usb-typec-anx7688-Port-to-Linux-6.10"
      {
        name = "usb: typec: anx7688: Add driver for ANX7688 USB-C HDMI bridge";
        patch = pkgs.fetchurl {
          # https://lore.kernel.org/lkml/ZhPM4XU8ttsFftBd@duo.ucw.cz/
          name = "usb: typec: anx7688: Add driver for ANX7688 USB-C HDMI bridge";
          url = "http://lore.kernel.org/lkml/ZhPM4XU8ttsFftBd@duo.ucw.cz/1-a.txt";
          hash = "sha256-doJOtaJLvepgagkQH0oqzVR9VQY4ZbK/3gx4kKgKnLg=";
        };
      }
      ### enable the ANX7688 in device tree
      # HDMI patches: because the Type C patch references the hdmi node, incidentally, so need to create that first
      byName."arm64-dts-allwinner-a64-Add-hdmi-sound-card"
      byName."arm64-dts-allwinner-a64-Enable-hdmi-sound-card-on-boards-with-h"
      # required for later patches to apply
      byName."arm64-dts-sun50i-a64-pinephone-Add-front-back-cameras"
      # this links ANX7688 into the pinephone-1.2 devicetree
      byName."arm64-dts-sun50i-a64-pinephone-Add-Type-C-support-for-all-PP-va"

      # enable /dev/modem-power; /sys/class/modem-power. my eg25-control script depends on it.
      # XXX(2024-09-01): NOT compatible with Linux 6.11
      byName."misc-modem-power-Power-manager-for-modems"
      byName."arm64-dts-sun50i-a64-pinephone-Add-modem-power-manager"

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
      # byName."dt-bindings-input-gpio-vibrator-Don-t-require-enable-gpios"
      # byName."input-gpio-vibra-Allow-to-use-vcc-supply-alone-to-control-the-v"
      # byName."dt-bindings-leds-Add-a-binding-for-AXP813-charger-led"
      # byName."leds-axp20x-Support-charger-LED-on-AXP20x-like-PMICs"
      # byName."ARM-dts-axp813-Add-charger-LED"
      # byName."media-i2c-gc2145-Move-upstream-driver-out-of-the-way"
      # byName."media-gc2145-Galaxycore-camera-module-driver"
      # byName."media-gc2145-Added-BGGR-bayer-mode"
      # byName."media-gc2145-Disable-debug-output"
      # byName."media-gc2145-Add-PIXEL_RATE-HBLANK-and-VBLANK-controls"
      # byName."media-gc2145-implement-system-suspend"
      # byName."media-gc2145-fix-white-balance-colors"
      # byName."media-i2c-gc2145-Parse-and-register-properties"
      # byName."mailbox-Allow-to-run-mailbox-while-timekeeping-is-suspended"
      # byName."firmware-scpi-Add-support-for-sending-a-SCPI_CMD_SET_SYS_PWR_ST"
      # byName."ARM-sunxi-Use-SCPI-to-send-suspend-message-to-SCP-on-A83T"
      # byName."arm64-dts-sun50i-h5-Use-my-own-more-aggressive-OPPs-on-H5"
      # byName."cpufreq-sun50i-Show-detected-CPU-bin-for-easier-debugging"
      # byName."net-stmmac-sun8i-Use-devm_regulator_get-for-PHY-regulator"
      # byName."net-stmmac-sun8i-Rename-PHY-regulator-variable-to-regulator_phy"
      # byName."net-stmmac-sun8i-Add-support-for-enabling-a-regulator-for-PHY-I"
      # byName."input-cyttsp4-De-obfuscate-platform-data-for-keys"
      # byName."input-cyttsp4-Remove-useless-indirection-with-driver-platform-d"
      # byName."input-cyttsp4-Remove-unused-enable_vkeys"
      # byName."input-cyttsp4-De-obfuscate-MT-signals-setup-platform-data"
      # byName."input-cyttsp4-Clear-the-ids-buffer-in-a-saner-way"
      # byName."input-cyttsp4-ENOSYS-error-is-ok-when-powering-up"
      # byName."input-cyttsp4-Faster-recovery-from-failed-wakeup-HACK"
      # byName."input-cyttsp4-Use-i2c-spi-names-directly-in-the-driver"
      # byName."input-cyttsp4-Port-the-driver-to-use-device-properties"
      # byName."input-cyttsp4-Restart-on-wakeup-wakeup-by-I2C-read-doesn-t-work"
      # byName."input-cyttsp4-Fix-warnings"
      # byName."input-cyttsp4-Make-the-driver-not-hog-the-system-s-workqueue"
      # byName."input-cyttsp4-Fix-probe-oops"
      # byName."regulator-Add-simple-driver-for-enabling-a-regulator-from-users"
      # byName."iio-adc-sun4i-gpadc-iio-Allow-to-use-sun5i-a13-gpadc-iio-from-D"
      # byName."mtd-spi-nor-Add-vdd-regulator-support"
      # byName."ARM-dts-sun5i-Add-soc-handle"
      # byName."arm64-dts-sun50i-a64-pinephone-Fix-BH-modem-manager-behavior"
      # byName."arm64-dts-sun50i-a64-pinephone-Add-detailed-OCV-to-capactiy-con"
      # byName."arm64-dts-sun50i-a64-pinephone-Shorten-post-power-on-delay-on-m"
      # byName."arm64-dts-sun50i-a64-pinephone-Add-mount-matrix-for-acceleromet"
      # byName."arm64-dts-sun50i-a64-pinephone-Add-support-for-Bluetooth-audio"
      # byName."arm64-dts-sun50i-a64-pinephone-Enable-internal-HMIC-bias"
      # byName."arm64-dts-sun50i-a64-pinephone-Add-support-for-modem-audio"
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
      # byName."arm64-dts-sun50i-a64-pinephone-Use-newer-jack-detection-impleme"
      # byName."arm64-dts-sun50-a64-pinephone-Define-jack-pins-in-DT"
      # byName."dt-bindings-sound-Add-jack-type-property-to-sun8i-a33-codec"
      # byName."ASoC-sun8i-codec-Allow-the-jack-type-to-be-set-via-device-tree"
      # byName."ASoC-sun8i-codec-define-button-keycodes"
      # byName."ASoC-sun8i-codec-Add-debug-output-for-jack-detection"
      # byName."ASoC-sun8i-codec-Set-jack_type-from-DT-in-probe"
      # byName."ASoC-simple-card-Allow-to-define-pins-for-aux-jack-devices"
      # byName."clk-sunxi-ng-a64-Increase-PLL_AUDIO-base-frequency"
      # byName."dt-bindings-mfd-Add-codec-related-properties-to-AC100-PMIC"
      # byName."sound-soc-ac100-codec-Support-analog-part-of-X-Powers-AC100-cod"
      # byName."sound-soc-sun8i-codec-Add-support-for-digital-part-of-the-AC100"
      # byName."ASoC-ec25-New-codec-driver-for-the-EC25-modem"
      # byName."ASOC-sun9i-hdmi-audio-Initial-implementation"
      # byName."arm64-dts-sun50i-a64-Set-fifo-size-for-uarts"
      # byName."Mark-some-slow-drivers-for-async-probe-with-PROBE_PREFER_ASYNCH"
      # byName."arm64-xor-Select-32regs-without-benchmark-to-speed-up-boot"
      # byName."clk-Implement-protected-clocks-for-all-OF-clock-providers"
      # byName."Revert-clk-qcom-Support-protected-clocks-property"
      # byName."arm64-dts-allwinner-a64-Protect-SCP-clocks"
      # byName."bus-sunxi-rsb-Always-check-register-address-validity"
      # byName."firmware-arm_scpi-Support-unidirectional-mailbox-channels"
      # byName."arm64-dts-allwinner-a64-Add-SCPI-protocol"
      # byName."rtc-sun6i-Allow-RTC-wakeup-after-shutdown"
      # byName."arm64-dts-sun50i-a64-Add-missing-trip-points-for-GPU"
      # byName."arm64-dts-allwinner-a64-Fix-LRADC-compatible"
      # byName."ASoC-codec-es8316-DAC-Soft-Ramp-Rate-is-just-a-2-bit-control"
      # byName."spi-rockchip-Fix-runtime-PM-and-other-issues"
      # byName."spi-fixes"
      # byName."media-cedrus-Fix-failure-to-clean-up-hardware-on-probe-failure"
      # byName."ASoC-rockchip-Fix-doubling-of-playback-speed-after-system-sleep"
      # byName."usb-musb-sunxi-Avoid-enabling-host-side-code-on-SoCs-where-it-s"
      # byName."arm64-dts-allwinner-Enforce-consistent-MMC-numbering"
      # byName."ARM-dts-sunxi-Add-aliases-for-MMC"
      # byName."drm-rockchip-Fix-panic-on-reboot-when-DRM-device-fails-to-bind"
      # byName."usb-gadget-Fix-dangling-pointer-in-netdev-private-data"
      # byName."Fix-for-usb-gadget-on-PP"
      # byName."mmc-dw-mmc-rockchip-fix-sdmmc-after-soft-reboot"
      # byName."Revert-drm-sun4i-lvds-Invert-the-LVDS-polarity"
      # byName."of-property-fw_devlink-Support-allwinner-sram-links"
      # byName."arm64-dts-rockchip-rk356x-Fix-PCIe-register-map-and-ranges"
      # byName."Fix-intptr_t-typedef"
      # byName."mmc-sunxi-mmc-Remove-runtime-PM"
      # byName."usb-serial-option-add-reset_resume-callback-for-WWAN-devices"
      # byName."media-rkisp1-Adapt-to-different-SoCs-having-different-size-limi"
      # byName."media-ov5648-Fix-call-to-pm_runtime_set_suspended"
      # byName."drm-rockchip-dw-mipi-dsi-rockchip-Fix-ISP1-PHY-initialization"
      # byName."drm-rockchip-dw-mipi-dsi-rockchip-Restore-DPHY-config-on-resume"
      # byName."bluetooth-h5-Don-t-re-initialize-rtl8723cs-on-resume"
      # byName."drm-sun4i-Unify-sun8i_-_layer-structs"
      # byName."drm-sun4i-Add-more-parameters-to-sunxi_engine-commit-callback"
      # byName."drm-sun4i-Fix-layer-zpos-change-atomic-modesetting"
      # byName."drm-sun4i-drm-Change-update_bits-to-write"
      # byName."drm-sun4i-Mark-one-of-the-UI-planes-as-a-cursor-one"
      # byName."drm-sun4i-Implement-gamma-correction"
      # byName."drm-panel-st7703-Fix-xbd599-timings-to-make-refresh-rate-exactl"
      # byName."drm-sun4i-Support-taking-over-display-pipeline-state-from-p-boo"
      # byName."video-pwm_bl-Allow-to-change-lth_brightness-via-sysfs"
      # byName."clk-sunxi-ng-sun50i-a64-Switch-parent-of-MIPI-DSI-to-periph0-1x"
      # byName."drm-sun4i-tcon-Support-keeping-dclk-rate-upon-ancestor-clock-ch"
      # byName."phy-allwinner-sun4i-usb-Add-support-for-usb_role_switch"
      # byName."regulator-axp20x-Add-support-for-vin-supply-for-drivevbus"
      # byName."regulator-axp20x-Turn-N_VBUSEN-to-input-on-x-powers-sense-vbus-"
      # byName."drm-bridge-dw-hdmi-Allow-to-accept-HPD-status-from-other-driver"
      # byName."drm-bridge-dw-hdmi-Report-HDMI-hotplug-events"
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
      # byName."sunxi-Use-dev_err_probe-to-handle-EPROBE_DEFER-errors"
      # byName."thermal-sun8i-Be-loud-when-probe-fails"
      # byName."i2c-mv64xxx-Don-t-make-a-fuss-when-pinctrl-recovery-state-is-no"
      # byName."iio-st_sensors-Don-t-report-error-when-the-device-is-not-presen"
      # byName."opp-core-Avoid-confusing-error-when-no-regulator-is-defined-in-"
      # byName."rtc-Print-which-error-caused-RTC-read-failure"
      # byName."usb-typec-fusb302-Slightly-increase-wait-time-for-BC1.2-result"
      # byName."usb-typec-fusb302-Set-the-current-before-enabling-pullups"
      # byName."usb-typec-fusb302-Extend-debugging-interface-with-driver-state-"
      # byName."usb-typec-fusb302-Retry-reading-of-CC-pins-status-if-activity-i"
      # byName."usb-typec-fusb302-More-useful-of-logging-status-on-interrupt"
      # byName."usb-typec-fusb302-Update-VBUS-state-even-if-VBUS-interrupt-is-n"
      # byName."usb-typec-fusb302-Add-OF-extcon-support"
      # byName."usb-typec-fusb302-Fix-register-definitions"
      # byName."usb-typec-fusb302-Clear-interrupts-before-we-start-toggling"
      # byName."usb-typec-typec-extcon-Add-typec-extcon-bridge-driver"
      # byName."usb-typec-typec-extcon-Enable-debugging-for-now"
      # byName."usb-typec-typec-extcon-Allow-to-force-reset-on-each-mux-change"
      # byName."Revert-usb-typec-tcpm-unregister-existing-source-caps-before-re"
      # byName."usb-typec-altmodes-displayport-Respect-DP_CAP_RECEPTACLE-bit"
      # byName."usb-typec-tcpm-Unregister-altmodes-before-registering-new-ones"
      # byName."usb-typec-tcpm-Fix-PD-devices-capabilities-registration"
      # byName."usb-typec-tcpm-Improve-logs"
      # byName."mtd-spi-nor-Add-Alliance-memory-support"
      # byName."Defconfigs-for-all-my-devices"
      # byName."Update-defconfigs"

      # {
      #   name = "fix-compilation-specific-to-megi";
      #   patch = null;
      #   extraStructuredConfig = with lib.kernel; {
      #     ### BUILD FIXES, NOT SPECIFIC TO MY PREFERENCES
      #     #
      #     # disabling the sun5i_eink driver avoids this compilation error:
      #     # CC [M]  drivers/video/fbdev/sun5i-eink-neon.o
      #     # aarch64-unknown-linux-gnu-gcc: error: unrecognized command line option '-mfloat-abi=softfp'
      #     # aarch64-unknown-linux-gnu-gcc: error: unrecognized command line option '-mfpu=neon'
      #     # make[3]: *** [../scripts/Makefile.build:289: drivers/video/fbdev/sun5i-eink-neon.o] Error 1
      #     FB_SUN5I_EINK = no;
      #     BES2600 = no;  # fails to compile (implicit declaration of function 'ieee80211_tx_status'; did you mean 'ieee80211_tx_status_ni')
      #   };
      # }
      {
        name = "fix-no-display";
        patch = null;
        extraStructuredConfig = with lib.kernel; {
          ### RUNTIME FIXES AFTER <https://github.com/NixOS/nixpkgs/pull/298332>
          # pmOS kernel config is in pmaports repo:
          # - CONFIG_FB_SIMPLE=y
          # - CONFIG_DRM_SIMPLEDRM is unset
          # - CONFIG_SYSFB_SIMPLEFB is not referenced
          # these config values are speculative: could probably be made smaller
          FB_SIMPLE = lib.mkForce yes;
          DRM_SIMPLEDRM = lib.mkForce no;  #< conflicts with FB_SIMPLE
          # SYSFB_SIMPLEFB = lib.mkForce no;
          # downgrade these from "yes" to "module", to match previous config.
          DRM = lib.mkForce module;
        };
      }
      {
        # this could be enabled for *all* systems, but i'm not sure i really want that.
        name = "quality-of-life";
        patch = null;
        extraStructuredConfig = with lib.kernel; {
          # optimize for faster builds.
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
          RAID6_PQ_BENCHMARK = no;
        };
      }
    ];

    # nixpkgs.hostPlatform.linux-kernel becomes stdenv.hostPlatform.linux-kernel
    # ^ but only if using flakes (or rather, if *not* using `nixpkgs.nixos` to construct the host config)
    # nixpkgs.hostPlatform.linux-kernel = {
    #   # defaults:
    #   name = "aarch64-multiplatform";
    #   # baseConfig: defaults to "defconfig";
    #   # baseConfig = "pinephone_defconfig";  #< N.B.: ignored by `pkgs.linux-megous`
    #   DTB = true;  #< DTB: compile device tree blobs
    #   # autoModules (default: true): for config options not manually specified, answer `m` to anything which supports it.
    #   # - this effectively builds EVERY MODULE SUPPORTED.
    #   autoModules = true;  #< N.B.: ignored by `pkgs.linux-megous`
    #   # preferBuiltin (default: false; true for rpi): for config options which default to `Y` upstream, build them as `Y` (overriding `autoModules`)
    #   # preferBuiltin = false;

    #   # build a compressed kernel image: without this i run out of /boot space in < 10 generations
    #   # target = "Image";  # <-- default
    #   target = "Image.gz";  # <-- compress the kernel image
    #   # target = "zImage";  # <-- confuses other parts of nixos :-(
    # };

    # boot.initrd.kernelModules = [
    #   "drm"  #< force drm to be plugged
    # ];
    boot.initrd.availableKernelModules = [
      # see <repo:postmarketOS/pmaports:device/main/device-pine64-pinephone/modules-initfs>
      # - they include sun6i_mipi_dsi sun4i_drm pwm_sun4i sun8i_mixer anx7688 gpio_vibra pinephone_keyboard
      "anx7688" #< required for display initialization and functional cameras
      # full list of modules active post-boot with the linux-megous kernel + autoModules=true:
      # - `lsmod | sort | cut -d ' ' -f 1`
      # "8723cs"
      # "axp20x_adc"  #< NOT FOUND in megous-no-autoModules
      # "axp20x_battery"
      # "axp20x_pek"
      # "axp20x_usb_power"
      # "backlight"
      # "blake2b_generic"
      # "bluetooth"
      # "bridge"
      # "btbcm"
      # "btqca"
      # "btrfs"
      # "btrtl"
      # "cec"
      # "cfg80211"
      # "chacha_neon"
      # "crc_ccitt"
      # "crct10dif_ce"
      # "crypto_engine"
      # "display_connector"  #< NOT FOUND in pmos
      # "drm"
      # "drm_display_helper"
      # "drm_dma_helper"
      # "drm_kms_helper"
      # "drm_shmem_helper"
      # "dw_hdmi"
      # "dw_hdmi_cec"  #< NOT FOUND in pmos
      # "dw_hdmi_i2s_audio"
      # "ecc"
      # "ecdh_generic"
      # "fuse"
      # "gc2145"  #< NOT FOUND in megous-no-autoModules
      # "goodix_ts"
      # "gpio_vibra"  #< NOT FOUND in megous-no-autoModules
      # "gpu_sched"
      # "hci_uart"
      # "i2c_gpio"
      # "inv_mpu6050"  #< NOT FOUND in megous-no-autoModules
      # "inv_mpu6050_i2c"  #< NOT FOUND in megous-no-autoModules
      # "inv_sensors_timestamp"  #< NOT FOUND in megous-no-autoModules
      # "ip6t_rpfilter"
      # "ip6_udp_tunnel"
      # "ip_set"
      # "ip_set_hash_ipport"
      # "ip_tables"
      # "ipt_rpfilter"
      # "joydev"
      # "led_class_flash"  #< NOT FOUND in megous-no-autoModules
      # "leds_sgm3140"  #< NOT FOUND in megous-no-autoModules
      # "ledtrig_pattern"  #< NOT FOUND in megous-no-autoModules
      # "libarc4"
      # "libchacha"
      # "libchacha20poly1305"
      # "libcrc32c"
      # "libcurve25519_generic"
      # "lima"
      # "llc"
      # "mac80211"
      # "macvlan"
      # "mc"
      # "modem_power"
      # "mousedev"
      # "nf_conntrack"
      # "nf_defrag_ipv4"
      # "nf_defrag_ipv6"
      # "nf_log_syslog"
      # "nf_nat"
      # "nfnetlink"
      # "nf_tables"
      # "nft_chain_nat"
      # "nft_compat"
      # "nls_cp437"
      # "nls_iso8859_1"
      # "nvmem_reboot_mode"
      # "ov5640"
      # "panel_sitronix_st7703"
      # "phy_sun6i_mipi_dphy"
      # "pinctrl_axp209"  #< NOT FOUND in pmos
      # "pinephone_keyboard"  #< NOT FOUND in megous-no-autoModules
      # "poly1305_neon"
      # "polyval_ce"
      # "polyval_generic"
      # "ppkb_manager"  #< NOT FOUND in megous-no-autoModules
      # "pwm_bl"
      # "pwm_sun4i"
      # "qrtr"
      # "raid6_pq"
      # "rfkill"
      # "rtw88_8703b"
      # "rtw88_8723cs"
      # "rtw88_8723x"
      # "rtw88_core"
      # "rtw88_sdio"
      # "sch_fq_codel"
      # "sm4"
      # "snd_soc_bt_sco"
      # "snd_soc_ec25"  #< NOT FOUND in megous-no-autoModules
      # "snd_soc_hdmi_codec"
      # "snd_soc_simple_amplifier"
      # "snd_soc_simple_card"
      # "snd_soc_simple_card_utils"
      # "stk3310"  #< NOT FOUND in megous-no-autoModules
      # "st_magn"
      # "st_magn_i2c"
      # "st_magn_spi"  #< NOT FOUND in pmos
      # "stp"
      # "st_sensors"
      # "st_sensors_i2c"
      # "st_sensors_spi"  #< NOT FOUND in pmos
      # "sun4i_drm"
      # "sun4i_i2s"
      # "sun4i_lradc_keys"  #< NOT FOUND in megous-no-autoModules
      # "sun4i_tcon"
      # "sun50i_codec_analog"
      # "sun6i_csi"
      # "sun6i_dma"
      # "sun6i_mipi_dsi"
      # "sun8i_a33_mbus"  #< NOT FOUND in megous-no-autoModules
      # "sun8i_adda_pr_regmap"
      # "sun8i_ce"  #< NOT FOUND in pmos
      # "sun8i_codec"  #< NOT FOUND in megous-no-autoModules
      # "sun8i_di"  #< NOT FOUND in megous-no-autoModules
      # "sun8i_drm_hdmi"
      # "sun8i_mixer"
      # "sun8i_rotate"  #< NOT FOUND in megous-no-autoModules
      # "sun8i_tcon_top"
      # "sun9i_hdmi_audio"  #< NOT FOUND in megous-no-autoModules
      # "sunxi_wdt"  #< NOT FOUND in pmos
      # "tap"
      # "typec"  #< NOT FOUND in pmos
      # "udp_tunnel"
      # "uio"  #< NOT FOUND in pmos
      # "uio_pdrv_genirq"
      # "v4l2_async"
      # "v4l2_cci" #< NOT FOUND in pmos
      # "v4l2_flash_led_class"  #< NOT FOUND in megous-no-autoModules
      # "v4l2_fwnode"
      # "v4l2_mem2mem"
      # "videobuf2_common"
      # "videobuf2_dma_contig"
      # "videobuf2_memops"
      # "videobuf2_v4l2"
      # "videodev"
      # "wireguard"
      # "xor"
      # "x_tables"
      # "xt_conntrack"
      # "xt_LOG"
      # "xt_nat"
      # "xt_pkttype"
      # "xt_set"
      # "xt_tcpudp"
      # "zram"
    ];
  };
}
