{ ... }:
{
  sane.programs.htop = {
    sandbox.keepPidsAndProc = true;
    sandbox.extraPaths = [
      "/sys/devices"
      "/sys/block"  # for zram usage
    ];
    sandbox.whitelistDbus = [ "system" ];  #< to show systemd job status
    fs.".config/htop/htoprc".symlink.target = ./htoprc;
  };
}
