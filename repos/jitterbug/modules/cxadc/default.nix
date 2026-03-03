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
          type = lib.types.nullOr (lib.types.addCheck lib.types.int (l: l >= -1 && l <= 3));
          default = null;
          description = ''
            Some TV cards have an external multiplexer attached to the CX2388x's GPIO pins to select an audio channel.
            If your card has one, you can select the input using this parameter.
          '';
        };

        center_offset = lib.mkOption {
          type = lib.types.nullOr (lib.types.addCheck lib.types.int (l: l >= -255 && l <= 255));
          default = null;
          description = ''
            This option allows you to manually adjust DC centre offset or the centring of the RF signal you wish to capture.
          '';
        };

        crystal = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = ''
            The Mhz of the actual XTAL crystal affixed to the board.
          '';
        };

        latency = lib.mkOption {
          type = lib.types.nullOr (lib.types.addCheck lib.types.int (l: l >= -255 && l <= 255));
          default = null;
          description = ''
            The PCI latency timer value for the device.
          '';
        };

        level = lib.mkOption {
          type = lib.types.nullOr (lib.types.addCheck lib.types.int (l: l >= -1 && l <= 31));
          default = null;
          description = ''
            The fixed digital gain to be applied by the CX2388x.
          '';
        };

        sixdb = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = ''
            Enables or disables a default 6db gain applied to the input signal.
          '';
        };

        tenbit = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = ''
            By default, cxadc captures unsigned 8-bit samples. In mode 1, unsigned 16-bit mode, the data is resampled (down-converted) by 50%.
          '';
        };

        tenxfsc = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.addCheck lib.types.int (l: (l >= 0 && l <= 2) || (l >= 10 && l <= 99) || l == 10022728)
          );
          default = null;
          description = ''
            Sets sampling rate of the ADC based on the crystal's native frequency.
          '';
        };

        vmux = lib.mkOption {
          type = lib.types.nullOr (lib.types.addCheck lib.types.int (l: l >= 0 && l <= 3));
          default = null;
          description = ''
            Select physical input to capture.
          '';
        };
      };
    };

  paramPath = "/sys/class/cxadc/cxadc*/device/parameters";
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

    group = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Group for /dev/cxadc* devices.
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

    services.udev.extraRules = ''
      ${if builtins.isString cfg.group then "KERNEL==\"cxadc*\", GROUP=\"${cfg.group}\"" else ""}
      ${
        if builtins.isString cfg.group then
          "KERNEL==\"cxadc*\", RUN+=\"${pkgs.stdenv.shell} -c 'chown -R root\:${cfg.group} ${paramPath} && chmod -R 770 ${paramPath}'\""
        else
          ""
      }
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: ''
          ${
            if builtins.isInt v.audsel then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/audsel}=\"${toString v.audsel}\""
            else
              ""
          }
          ${
            if builtins.isInt v.center_offset then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/center_offset}=\"${toString v.center_offset}\""
            else
              ""
          }
          ${
            if builtins.isInt v.crystal then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/crystal}=\"${toString v.crystal}\""
            else
              ""
          }
          ${
            if builtins.isInt v.latency then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/latency}=\"${toString v.latency}\""
            else
              ""
          }
          ${
            if builtins.isInt v.level then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/level}=\"${toString v.level}\""
            else
              ""
          }
          ${
            if builtins.isBool v.sixdb then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/sixdb}=\"${if v.sixdb then "1" else "0"}\""
            else
              ""
          }
          ${
            if builtins.isBool v.tenbit then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/tenbit}=\"${if v.tenbit then "1" else "0"}\""
            else
              ""
          }
          ${
            if builtins.isInt v.tenxfsc then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/tenxfsc}=\"${toString v.tenxfsc}\""
            else
              ""
          }
          ${
            if builtins.isInt v.vmux then
              "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/vmux}=\"${toString v.vmux}\""
            else
              ""
          }
        '') cfg.parameters
      )}
    '';
  };

  meta = {
    inherit maintainers;
  };
}
