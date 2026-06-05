{ config, lib, ... }:
let
  cfg = config.sane.hal.intel;
in
{
  options = {
    sane.hal.intel.enable = lib.mkEnableOption "intel-specific hardware support";
  };

  config = lib.mkIf cfg.enable {
    # XXX(2025-12-29): intel processors don't support the `ondemand` cpu governor (which i use on all other systems).
    # moreover, `cpufreq.service` logs error if configured for an unsupported governor.
    #
    # this is fine: intel_pstate manages scaling w/o OS intervention.
    powerManagement.cpuFreqGovernor = null;
  };
}

