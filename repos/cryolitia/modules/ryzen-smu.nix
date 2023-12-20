{ config, lib, pkgs, ... }:

with lib;

let

  ryzen-smu = config.boot.kernelPackages.callPackage ../pkgs/common/ryzen-smu.nix { };

  ryzenadjCheck = lib.warnIf (builtins.elem pkgs.ryzenadj config.environment.systemPackages)
    "ryzenadj is in environment.systemPackages, enable hardware.cpu.amd.ryzen-smu to enhance it.";

in
{

  meta.maintainers = [ maintainers.Cryolitia ];

  ###### interface

  options = {

    hardware.cpu.amd.ryzen-smu.enable = mkOption {
      default = false;
      type = types.bool;
      description = mdDoc ''
        Enable ryzen_smu for AMD processors to aceess the SMU (System Management Unit).
      '';
    };
  };

  ###### implementation

  config = mkIf config.hardware.cpu.amd.ryzen-smu.enable {
    boot.extraModulePackages = [ ryzen-smu ];
    boot.kernelModules = [ "ryzen_smu" ];
    environment.systemPackages = [ ryzen-smu ];
  };
}
