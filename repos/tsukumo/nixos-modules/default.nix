{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  yogabook = { config, lib, pkgs, ... }:
    let
      cfg = config.hardware.yogabook;

      yogabook-linux = pkgs.callPackage ../pkgs/yogabook-linux.nix {};

      # Expose packages from consolidated set
      touch-keyboard = yogabook-linux.touch-keyboard;
      yogabook-modes-handler = yogabook-linux.yogabook-modes-handler;
      iio-sensor-proxy-yogabook = yogabook-linux.iio-sensor-proxy-yogabook;
      yogabook-kernel = yogabook-linux.yogabook-kernel;

      # Expose src for alsa-ucm-conf overriding
      yogabook-src = yogabook-linux.src;

      # Create custom alsa-ucm-conf with Yoga Book configs merged
      alsa-ucm-conf-yogabook = pkgs.runCommand "alsa-ucm-conf-yogabook" {} ''
        mkdir -p $out/share/alsa/ucm2
        cp -r ${pkgs.alsa-ucm-conf}/share/alsa/ucm2/* $out/share/alsa/ucm2/
        chmod -R +w $out/share/alsa/ucm2
        cp -r ${yogabook-src}/alsa-ucm-conf-yogabook/ucm2/* $out/share/alsa/ucm2/
      '';
    in {
      options.hardware.yogabook = {
        enable = lib.mkEnableOption "Lenovo Yoga Book YB1 hardware support";
        useCustomKernel = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to use the custom patched Yoga Book kernel. Disabling this will use the default NixOS kernel.";
        };
      };

      config = lib.mkIf cfg.enable {
        # Custom kernel setup
        boot.kernelPackages = lib.mkIf cfg.useCustomKernel (pkgs.linuxPackagesFor yogabook-kernel);

        # Kernel command-line parameters for screen rotation and power management
        boot.kernelParams = [
          "video=efifb:width:1200,stride:1200,height:1920"
          "fbcon=rotate:1"
          "random.trust_cpu=1"
          "systemd.restore_state=0"
        ];

        # Enable firmware
        hardware.enableRedistributableFirmware = true;

        # Nixpkgs Overlay to replace iio-sensor-proxy
        nixpkgs.overlays = [
          (final: prev: {
            iio-sensor-proxy = iio-sensor-proxy-yogabook;
          })
        ];

        # Override UCM2 directory via environment variable to avoid rebuilds of GUI apps
        environment.sessionVariables = {
          ALSA_CONFIG_UCM2 = "${alsa-ucm-conf-yogabook}/share/alsa/ucm2";
        };

        # Disable default initrd modules to prevent adding unavailable legacy storage modules (ahci, ata_piix, etc.)
        boot.initrd.includeDefaultModules = false;
        boot.initrd.availableKernelModules = [
          "sdhci_acpi"
          "xhci_pci"
          "usbhid"
          "hid_generic"
          "usb_storage"
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
        };

        # Configuration layout files placement
        environment.etc."touch_keyboard".source = "${touch-keyboard}/etc/touch_keyboard";
      };
    };
}
