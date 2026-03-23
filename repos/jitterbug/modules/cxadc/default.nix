{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.cxadc;
  cxadc = config.boot.kernelPackages.callPackage (import ../../pkgs/decode-hardware/cxadc) {
    inherit maintainers;
  };

  maintainers = import ../../maintainers.nix;

  cxParameters =
    { ... }:
    {
      options = {
        audsel = lib.mkOption {
          type = lib.types.addCheck lib.types.int (l: l >= -1 && l <= 3);
          default = -1;
          description = ''
            Some TV cards have an external multiplexer attached to the CX2388x's GPIO pins to select an audio channel.
            If your card has one, you can select the input using this parameter.
          '';
        };

        center_offset = lib.mkOption {
          type = lib.types.addCheck lib.types.int (l: l >= 0 && l <= 255);
          default = 2;
          description = ''
            This option allows you to manually adjust DC centre offset or the centring of the RF signal you wish to capture.
          '';
        };

        crystal = lib.mkOption {
          type = lib.types.int;
          default = 28636363;
          description = ''
            The Mhz of the actual XTAL crystal affixed to the board.
          '';
        };

        latency = lib.mkOption {
          type = lib.types.addCheck lib.types.int (l: l >= -1 && l <= 255);
          default = -1;
          description = ''
            The PCI latency timer value for the device.
          '';
        };

        level = lib.mkOption {
          type = lib.types.addCheck lib.types.int (l: l >= 0 && l <= 31);
          default = 16;
          description = ''
            The fixed digital gain to be applied by the CX2388x.
          '';
        };

        sixdb = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Enables or disables a default 6db gain applied to the input signal.
          '';
        };

        tenbit = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            By default, cxadc captures unsigned 8-bit samples. In mode 1, unsigned 16-bit mode, the data is resampled (down-converted) by 50%.
          '';
        };

        tenxfsc = lib.mkOption {
          type = lib.types.addCheck lib.types.int (
            l: (l >= 0 && l <= 2) || (l >= 10 && l <= 99) || l == 10022728
          );
          default = 0;
          description = ''
            Sets sampling rate of the ADC based on the crystal's native frequency.
          '';
        };

        vmux = lib.mkOption {
          type = lib.types.addCheck lib.types.int (l: l >= 0 && l <= 3);
          default = 2;
          description = ''
            Select physical input to capture.
          '';
        };
      };
    };

  devPath = "${devPath}";
  sysfsPath = "/sys/class/cxadc/cxadc*/device/parameters";
in
{
  options.hardware.cxadc = {
    enable = lib.mkEnableOption "cxadc";

    exportVersionVariable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Set the env variable __CXADC_VERSION.
      '';
    };

    setPermissions = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Set permissions on ${devPath} and ${sysfsPath}
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "video";
      description = ''
        ${devPath} and ${sysfsPath} group.
      '';
    };

    devMode = lib.mkOption {
      type = lib.types.str;
      default = "0550";
      description = ''
        ${devPath} mode.
      '';
    };

    sysfsMode = lib.mkOption {
      type = lib.types.str;
      default = "0770";
      description = ''
        ${sysfsPath} mode.
      '';
    };

    parameters = lib.mkOption {
      description = "Parameters for cxadc devices.";
      type = lib.types.attrsOf (lib.types.submodule cxParameters);
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      extraModulePackages = [
        cxadc
      ];

      kernelModules = [
        "cxadc"
      ];

      blacklistedKernelModules = [
        "cx88_alsa"
        "cx8800"
        "cx88xx"
        "cx8802"
        "cx88_blackbird"
        "cx2341x"
      ];
    };

    environment = {
      systemPackages = [
        cxadc
      ];

      sessionVariables = lib.mkIf cfg.exportVersionVariable {
        "__CXADC_VERSION" = cxadc.src.rev;
      };
    };

    services.udev.extraRules = lib.optionalString (cfg.setPermissions != null) ''
      KERNEL=="cxadc*", MODE="${cfg.devMode}", GROUP="${cfg.group}"
      KERNEL=="cxadc*", RUN+="${pkgs.stdenv.shell} -c 'chgrp -R ${cfg.group} ${sysfsPath}'"
      KERNEL=="cxadc*", RUN+="${pkgs.stdenv.shell} -c 'chmod -R ${cfg.sysfsMode} ${sysfsPath}'"
    '';

    boot.kernel.sysfs.class.cxadc = lib.mapAttrs (name: value: {
      device.parameters = {
        inherit (value)
          audsel
          center_offset
          crystal
          latency
          level
          sixdb
          tenbit
          tenxfsc
          vmux
          ;
      };
    }) cfg.parameters;
  };

  meta = {
    inherit maintainers;
  };
}
