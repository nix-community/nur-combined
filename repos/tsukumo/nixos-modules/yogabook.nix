{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.yogabook;

  yogabook-linux = pkgs.callPackage ../pkgs/yogabook-linux.nix {};

  inherit (yogabook-linux)
    touch-keyboard
    yogabook-modes-handler
    iio-sensor-proxy-yogabook;

  # Expose src for alsa-ucm-conf overriding
  yogabook-src = yogabook-linux.src;

  # Create custom alsa-ucm-conf with Yoga Book configs merged
  alsa-ucm-conf-yogabook = pkgs.runCommand "alsa-ucm-conf-yogabook" {} ''
    mkdir -p $out/share/alsa/ucm2
    cp -r ${pkgs.alsa-ucm-conf}/share/alsa/ucm2/* $out/share/alsa/ucm2/
    chmod -R +w $out/share/alsa/ucm2
    cp -r ${yogabook-src}/alsa-ucm-conf-yogabook/ucm2/* $out/share/alsa/ucm2/
  '';

  # Custom layout files shipped in this NUR repo (e.g. jp106)
  customLayouts = ../pkgs/layouts;

  # Create custom etc directory for touch-keyboard with layout.csv symlink
  touch-keyboard-etc = pkgs.runCommand "touch-keyboard-etc" {} ''
    mkdir -p $out
    cp -r ${touch-keyboard}/etc/touch_keyboard/* $out/
    chmod -R +w $out/layouts
    # Overlay custom layouts from our repo (adds jp106 etc.)
    cp ${customLayouts}/*.csv $out/layouts/ 2>/dev/null || true
    ln -sf layouts/YB1-X9x-${cfg.keyboardLayout}.csv $out/layout.csv
  '';

  # Kernel modules required for Yoga Book hardware
  yogabookKernelModules = [
    "lenovo-yogabook"
    "x86-android-tablets"
    "drv260x"
    "hideep"
    "uinput"
    "i2c-dev"
    "goodix_ts"
    "i2c-designware-platform"
    "i2c-designware-core"
  ];
in
{
  options.hardware.yogabook = {
    enable = lib.mkEnableOption "Lenovo Yoga Book YB1 hardware support";
    useCustomKernel = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use the custom patched Yoga Book kernel. Disabling this will use the default NixOS kernel.";
    };
    keyboardLayout = lib.mkOption {
      type = lib.types.enum [ "pc104" "pc105" "jp106" ];
      default = "pc105";
      description = "The physical keyboard layout of the Yoga Book (pc104 for US, pc105 for EU/ISO, jp106 for Japanese JIS).";
    };
    chargeTargetVoltage = lib.mkOption {
      type = lib.types.enum [ 9 12 ];
      default = 9;
      description = "Target charging voltage in Volts for Pump Express fast charging (9V or 12V).";
    };
    enableHapticCalibration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to calibrate haptic motors on boot (causes vibration at startup).";
    };
    chargeInputCurrentLimit = lib.mkOption {
      type = lib.types.int;
      default = 2000000;
      description = "Input current limit in microAmps (µA) for charging (e.g. 2000000 for 2A, 3000000 for 3A).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Custom kernel setup (mutually exclusive with out-of-tree modules below)
    boot.kernelPackages = lib.mkIf cfg.useCustomKernel
      (pkgs.linuxPackagesFor yogabook-linux.yogabook-config);

    # Extra kernel modules compiled out-of-tree for the standard NixOS kernel
    boot.extraModulePackages = lib.mkIf (!cfg.useCustomKernel) [
      (yogabook-linux.yogabook-modules {
        inherit (config.boot.kernelPackages) kernel kernelModuleMakeFlags;
        inherit (cfg) enableHapticCalibration;
      })
    ];

    # Load necessary modules in order on boot
    boot.kernelModules = yogabookKernelModules;

    # Required for LUKS password entry via touch keyboard in initrd
    boot.initrd.kernelModules = yogabookKernelModules;

    # Udev rules in initrd (symlink touch keyboard device for the handler)
    boot.initrd.services.udev.rules = ''
      # Tag Goodix Capacitive TouchScreen with TOUCH_KEYBOARD=1 directly
      ACTION=="add|change", SUBSYSTEM=="input", ATTRS{name}=="Goodix Capacitive TouchScreen", ENV{TOUCH_KEYBOARD}="1"

      # Symlink touchscreen digitizer for the keyboard driver
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ENV{TOUCH_KEYBOARD}=="1", SYMLINK+="touch_keyboard", TAG+="systemd", ENV{SYSTEMD_WANTS}+="touch-keyboard-handler.service"
    '';

    # Copy layout config into initrd
    boot.initrd.systemd.contents = {
      "/etc/touch_keyboard".source = touch-keyboard-etc;
    };

    # Start touch-keyboard-handler in initrd (enables typing LUKS passphrase)
    boot.initrd.systemd.services.touch-keyboard-handler = {
      description = "Touch keyboard handler in initrd";
      wantedBy = [ "initrd.target" ];
      after = [ "initrd-root-device.target" ];
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/etc/touch_keyboard";
        ExecStart = "${touch-keyboard}/bin/touch_keyboard_handler -m 1.0 -D 6";
        DefaultDependencies = false;
      };
    };

    # Kernel command-line parameters for screen rotation and power management
    boot.kernelParams = [
      "video=efifb:width:1200,stride:1200,height:1920"
      "fbcon=rotate:1"
      "random.trust_cpu=1"
      "systemd.restore_state=0"
    ];

    # Enable firmware
    hardware.enableRedistributableFirmware = true;

    # Replace iio-sensor-proxy with the patched Yoga Book version
    nixpkgs.overlays = [
      (_final: _prev: {
        iio-sensor-proxy = iio-sensor-proxy-yogabook;
      })
    ];

    # Override UCM2 directory via environment variable to avoid rebuilds of GUI apps
    environment.sessionVariables = {
      ALSA_CONFIG_UCM2 = "${alsa-ucm-conf-yogabook}/share/alsa/ucm2";
    };

    # Disable default initrd modules when using the custom kernel to prevent
    # errors from missing legacy storage modules (ahci, ata_piix, etc.) and
    # keyboard modules (atkbd, i8042) which are not built in the custom kernel.
    boot.initrd.includeDefaultModules = lib.mkDefault (!cfg.useCustomKernel);
    boot.initrd.availableKernelModules = lib.mkIf cfg.useCustomKernel [
      # Storage / MMC
      "sdhci"
      "sdhci_acpi"
      "sdhci_pci"
      "mmc_block"
      "cqhci"
      # DMA Engine (required for sdhci DMA on Intel Cherry Trail)
      "idma64"
      # Intel LPSS (Required for clock/power of SDHCI/eMMC controllers)
      "intel-lpss"
      "intel-lpss-acpi"
      "intel-lpss-pci"
      # USB OTG / Dual-Role Controller (Required for Cherry Trail USB ports)
      "dwc3"
      "dwc3_pci"
      "extcon-intel-cht-wc"
      "extcon-intel-int3496"
      "nop-usb-xceiv"
      # USB Host Controllers
      "xhci_pci"
      "ehci_pci"
      "ohci_pci"
      "uhci_hcd"
      # USB Input / Storage
      "usbhid"
      "hid_generic"
      "usb_storage"
      "uas"
      "sd_mod"
    ];

    # Udev Rules
    services.udev.extraRules = ''
      # Symlink touchscreen digitizer for the keyboard driver
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ENV{TOUCH_KEYBOARD}=="1", SYMLINK+="touch_keyboard", TAG+="systemd", ENV{SYSTEMD_WANTS}+="touch-keyboard-handler.service"

      # DRV2604 Haptic vibrators symlinks
      KERNEL=="event*", SUBSYSTEM=="input", KERNELS=="i2c-DRV2604:00", SYMLINK+="right_vibrator"
      KERNEL=="event*", SUBSYSTEM=="input", KERNELS=="i2c-DRV2604:01", SYMLINK+="left_vibrator"
      KERNEL=="event*", SUBSYSTEM=="input", KERNELS=="i2c-drv2604l.0", SYMLINK+="right_vibrator"
      KERNEL=="event*", SUBSYSTEM=="input", KERNELS=="i2c-drv2604l.1", SYMLINK+="left_vibrator"

      # Import sensor HWDB rules
      ACTION=="add|change", SUBSYSTEM=="iio", KERNEL=="iio*", SUBSYSTEMS=="usb|i2c|platform", IMPORT{builtin}="hwdb 'sensor:modalias:$attr{modalias}:id:$id:$attr{[dmi/id]modalias}'"

      # Trigger Pump Express handshake when charger is plugged in
      SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="cht_wcove_pwrsrc", ENV{POWER_SUPPLY_ONLINE}=="1", ENV{POWER_SUPPLY_USB_TYPE}=="*DCP*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="pe-handshake.service"

      # Set input current limit for bq25890 charger when added or changed
      SUBSYSTEM=="power_supply", KERNEL=="bq25890-charger-*", ACTION=="add|change", RUN+="${pkgs.bash}/bin/bash -c 'echo ${toString cfg.chargeInputCurrentLimit} > /sys/class/power_supply/%k/input_current_limit'"
    '';

    # HWDB Settings
    services.udev.extraHwdb = ''
      sensor:modalias:platform:HID-SENSOR-200073:id:HID-SENSOR-200073.10.auto:dmi:bvnLENOVO*pnLenovoYB1-X9*
       ACCEL_LOCATION=display

      sensor:modalias:platform:HID-SENSOR-200073:id:HID-SENSOR-200073.11.auto:dmi:bvnLENOVO*pnLenovoYB1-X9*
       ACCEL_LOCATION=base
       ACCEL_MOUNT_MATRIX=0, 1, 0; -1, 0, 0; 0, 0, 1

      sensor:modalias:platform:HID-SENSOR-200073:id:HID-SENSOR-200073.19.auto:dmi:bvnLENOVO*pnLenovoYB1-X9*
       ACCEL_LOCATION=display

      sensor:modalias:platform:HID-SENSOR-200073:id:HID-SENSOR-200073.20.auto:dmi:bvnLENOVO*pnLenovoYB1-X9*
       ACCEL_LOCATION=base
       ACCEL_MOUNT_MATRIX=0, 1, 0; -1, 0, 0; 0, 0, 1

      evdev:name:Goodix Capacitive TouchScreen:dmi:bvnLENOVO*pnLenovoYB1-X9*
       TOUCH_KEYBOARD=1
       LIBINPUT_IGNORE_DEVICE=1

      evdev:name:Goodix Capacitive TouchScreen:dmi:*pnCHERRYVIEWD1PLATFORM*:pvrYETI-11*:*
       TOUCH_KEYBOARD=1
       LIBINPUT_IGNORE_DEVICE=1

      evdev:name:virtual-touchpad:dmi:bvnLENOVO*pnLenovoYB1-X9*
       ID_INPUT_TOUCHPAD_INTEGRATION=internal

      evdev:name:virtual-touchpad:dmi:*pnCHERRYVIEWD1PLATFORM*:pvrYETI-11*:*
       ID_INPUT_TOUCHPAD_INTEGRATION=internal
    '';

    # Systemd Daemons
    systemd.services = {
      monitor-sensor = {
        description = "Hinge Angle sensor monitor";
        after = [ "iio-sensor-proxy.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${iio-sensor-proxy-yogabook}/bin/monitor-sensor --hinge";
        };
      };

      touch-keyboard-handler = {
        description = "Touch keyboard handler";
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ touch-keyboard-etc ];
        serviceConfig = {
          Type = "simple";
          WorkingDirectory = "/etc/touch_keyboard";
          ExecStart = "${touch-keyboard}/bin/touch_keyboard_handler -m 1.0 -D 6";
        };
      };

      yogabook-modes-handler = {
        description = "Yoga Book modes handler";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${yogabook-modes-handler}/bin/yogabook-modes-handler";
          StandardOutput = "journal";
        };
      };

      pe-handshake = {
        description = "Yoga Book Pump Express High Voltage Charge Handshake";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScript "pe-handshake" ''
            # Enable PUMPX_EN (Reg 4 -> 0xc2)
            echo "Enabling PUMPX_EN..."
            ${pkgs.i2c-tools}/bin/i2cset -f -y 7 0x6b 4 0xc2

            prev_voltage_mv=0
            for i in {1..8}; do
              echo "--- Try $i ---"
              # Read current VBUS
              vbus_raw=$(${pkgs.i2c-tools}/bin/i2cget -f -y 7 0x6b 17)
              vbus_dec=$((vbus_raw & 0x7f))
              # 2.6V + 0.1V * vbus_dec
              voltage_mv=$((2600 + vbus_dec * 100))
              echo "Current VBUS voltage: ''${voltage_mv} mV"

              # Stop if we reached target voltage
              if [ $voltage_mv -gt ${if cfg.chargeTargetVoltage == 12 then "10500" else "8000"} ]; then
                echo "Voltage is high! Handshake succeeded!"
                break
              fi

              if [ $i -gt 1 ] && [ $voltage_mv -le $prev_voltage_mv ]; then
                echo "Voltage did not increase. Stopping."
                break
              fi

              prev_voltage_mv=$voltage_mv

              echo "Sending PUMPX_UP pulse..."
              ${pkgs.i2c-tools}/bin/i2cset -f -y 7 0x6b 9 0x46

              # Wait for it to clear
              echo "Waiting for pulse to complete..."
              for w in {1..40}; do
                reg9=$(${pkgs.i2c-tools}/bin/i2cget -f -y 7 0x6b 9)
                if [ $((reg9 & 0x02)) -eq 0 ]; then
                  echo "Pulse complete after $w iterations"
                  break
                fi
                sleep 0.1
              done

              sleep 1.0
            done

            # Disable PUMPX_EN (Reg 4 -> 0x42)
            echo "Disabling PUMPX_EN..."
            ${pkgs.i2c-tools}/bin/i2cset -f -y 7 0x6b 4 0x42
          ''}";
        };
      };
    };

    # Configuration layout files placement
    environment.etc."touch_keyboard".source = touch-keyboard-etc;
  };
}
