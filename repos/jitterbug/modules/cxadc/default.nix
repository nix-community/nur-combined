{ config
, lib
, pkgs
, ...
}:

with lib;
with types;

let
  cfg = config.hardware.cxadc;
  cxadc = config.boot.kernelPackages.callPackage (import ./cxadc.nix) { };

  cxParameters = { ... }: {
    options = {
      audsel = mkOption {
        type = nullOr (addCheck int (l: l >= -1 && l <= 3));
        default = null;
        description = ''
          Some TV cards have an external multiplexer attached to the CX2388x's GPIO pins to select an audio channel.
          If your card has one, you can select the input using this parameter.
        '';
      };

      center_offset = mkOption {
        type = nullOr (addCheck int (l: l >= -255 && l <= 255));
        default = null;
        description = ''
          This option allows you to manually adjust DC centre offset or the centring of the RF signal you wish to capture.
        '';
      };

      crystal = mkOption {
        type = nullOr int;
        default = null;
        description = ''
          The Mhz of the actual XTAL crystal affixed to the board.
        '';
      };

      latency = mkOption {
        type = nullOr (addCheck int (l: l >= -255 && l <= 255));
        default = null;
        description = ''
          The PCI latency timer value for the device.
        '';
      };

      level = mkOption {
        type = nullOr (addCheck int (l: l >= -1 && l <= 31));
        default = null;
        description = ''
          The fixed digital gain to be applied by the CX2388x.
        '';
      };

      sixdb = mkOption {
        type = nullOr bool;
        default = null;
        description = ''
          Enables or disables a default 6db gain applied to the input signal.
        '';
      };

      tenbit = mkOption {
        type = nullOr bool;
        default = null;
        description = ''
          By default, cxadc captures unsigned 8-bit samples. In mode 1, unsigned 16-bit mode, the data is resampled (down-converted) by 50%.
        '';
      };

      tenxfsc = mkOption {
        type = nullOr (addCheck int (l: (l >= 0 && l <= 2) || (l >= 10 && l <= 99) || l == 10022728));
        default = null;
        description = ''
          Sets sampling rate of the ADC based on the crystal's native frequency.
        '';
      };

      vmux = mkOption {
        type = nullOr (addCheck int (l: l >= 0 && l <= 3));
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
    enable = mkEnableOption "cxadc";

    exportVersionVariable = mkOption {
      type = bool;
      default = false;
      description = ''
        Set the env variable __CXADC_VERSION.
      '';
    };

    group = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Group for /dev/cxadc* devices.
      '';
    };

    parameters = mkOption {
      description = "Parameters for cxadc devices.";
      type = attrsOf (submodule cxParameters);
    };
  };

  config = mkIf cfg.enable {
    boot = {
      extraModulePackages = [ cxadc ];
      kernelModules = [ "cxadc" ];
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
      systemPackages = [ cxadc ];
      sessionVariables = mkIf cfg.exportVersionVariable {
        "__CXADC_VERSION" = cxadc.src.rev;
      };
    };

    services.udev.extraRules = with builtins; ''
      ${if isString cfg.group then "KERNEL==\"cxadc*\", GROUP=\"${cfg.group}\"" else ""}
      ${if isString cfg.group then "KERNEL==\"cxadc*\", RUN+=\"${pkgs.stdenv.shell} -c 'chown -R root\:${cfg.group} ${paramPath} && chmod -R 770 ${paramPath}'\"" else ""}
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: ''
        ${if isInt v.audsel then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/audsel}=\"${toString v.audsel}\"" else ""}
        ${if isInt v.center_offset then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/center_offset}=\"${toString v.center_offset}\"" else ""}
        ${if isInt v.crystal then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/crystal}=\"${toString v.crystal}\"" else ""}
        ${if isInt v.latency then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/latency}=\"${toString v.latency}\"" else ""}
        ${if isInt v.level then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/level}=\"${toString v.level}\"" else ""}
        ${if isBool v.sixdb then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/sixdb}=\"${if v.sixdb then "1" else "0"}\"" else ""}
        ${if isBool v.tenbit  then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/tenbit}=\"${if v.tenbit then "1" else "0"}\"" else ""}
        ${if isInt v.tenxfsc then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/tenxfsc}=\"${toString v.tenxfsc}\"" else ""}
        ${if isInt v.vmux then "KERNEL==\"${n}\", SUBSYSTEM==\"cxadc\", ATTR{device/parameters/vmux}=\"${toString v.vmux}\"" else ""}
      '') cfg.parameters)}
    '';
  };

  meta = {
    maintainers = [ "JuniorIsAJitterbug" ];
  };
}
