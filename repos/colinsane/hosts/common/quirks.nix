# quirks: temporary patches with the goal of eventually removing them
{ ... }:
{
  # bug in linux 6.8(?), fixed by linux 6.9. see: <https://github.com/axboe/liburing/issues/1113>
  # - <https://github.com/neovim/neovim/issues/28149>
  # - <https://git.kernel.dk/cgit/linux/commit/?h=io_uring-6.9&id=e5444baa42e545bb929ba56c497e7f3c73634099>
  # when removing, try starting and suspending (ctrl+z) two instances of neovim simultaneously.
  # if the system doesn't freeze, then this is safe to remove.
  # added 2024-04-04
  # removed 2024-08-31
  # sane.user.fs.".profile".symlink.text = lib.mkBefore ''
  #   export UV_USE_IO_URING=0
  # '';

  # powertop will default to putting USB devices -- including HID -- to sleep after TWO SECONDS
  powerManagement.powertop.enable = false;
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
  powerManagement.cpuFreqGovernor = "ondemand";
}
