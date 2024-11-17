{ ... }:
{
  sane.programs.sane-sysload = {
    sandbox.extraPaths = [
      "/sys/class/power_supply"
      "/sys/devices"
    ];
    fs.".profile".symlink.text = ''
      maybeShowSysload() {
        # show ssh users the current resource usage.
        # especially useful for moby (to see battery)
        if [ -n "$SSH_TTY" ]; then
          sane-sysload
        fi
      }
      sessionCommands+=('maybeShowSysload')
    '';
  };
}
