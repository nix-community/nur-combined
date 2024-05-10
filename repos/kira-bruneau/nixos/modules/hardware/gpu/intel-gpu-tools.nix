{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.intel-gpu-tools;
in
{
  options = {
    hardware.intel-gpu-tools = {
      enable = mkEnableOption "a setcap wrapper for intel-gpu-tools";
    };
  };

  config = mkIf cfg.enable {
    security.wrappers.intel_gpu_top = {
      owner = "root";
      group = "root";
      source = "${pkgs.intel-gpu-tools}/bin/intel_gpu_top";
      capabilities = "cap_perfmon+ep";
    };
  };

  meta = {
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
