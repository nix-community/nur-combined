# quirks: temporary patches with the goal of eventually removing them
{ lib, ... }:
{
  # powertop will default to putting USB devices -- including HID -- to sleep after TWO SECONDS
  powerManagement.powertop.enable = false;

  # XXX(2026-07-13): attempting to defeat flowy trackpad bug where after days of power-on,
  # the elan trackpad suddenly enters a degraded state.
  # observe with `sudo evtest /dev/input/event9`: while dragging across the trackpad,
  # it will suddenly cut out for ~200ms at a time.
  #
  # this is alternately solved by **closing and re-opening the lid**,
  # which likely cuts power to the trackpad in firmware (beneath the OS).
  boot.kernelParams = [ "i2c_hid_acpi.disable_runtime_pm=1" ];

  # linux CPU governor: <https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt>
  # - options:
  #   - "powersave" => force CPU to always run at lowest supported frequency
  #   - "performance" => force CPU to always run at highest frequency
  #   - "ondemand" => adjust frequency based on load
  #   - "conservative"  (ondemand but slower to adjust)
  #   - "schedutil"
  #   - "userspace"
  # - not all options are available for all platforms
  #   - intel (intel_pstate) appears to manage scaling w/o intervention/control from the OS.
  #   - AMD (acpi-cpufreq) appears to manage scaling via the OS *or* HW. but the ondemand defaults never put it to max hardware frequency.
  #   - qualcomm (cpufreq-dt) appears to manage scaling *only* via the OS. ondemand governor exercises the full range.
  # - query details with `sudo cpupower frequency-info`
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
