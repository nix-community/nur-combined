# N.B.(2025-07-23):
# - gpu stats require `BUNPEN_DISABLE=1`.
#   these are obtained via /proc/$super/fdinfo;
#   <https://www.kernel.org/doc/html/latest/gpu/drm-usage-stats.html>
#   no idea if this is a fundamental thing (drm subsystem is namespace unaware),
#   or something else.
{ ... }:
{
  sane.programs.htop = {
    sandbox.keepPidsAndProc = true;
    sandbox.extraPaths = [
      "/sys/devices"
      "/sys/block"  # for zram usage
    ];
    sandbox.whitelistDbus.system = true;  #< to show systemd job status
    fs.".config/htop/htoprc".symlink.target = ./htoprc;
  };
}
