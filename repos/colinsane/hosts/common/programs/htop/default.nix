{ ... }:
{
  sane.programs.htop = {
    sandbox.keepPidsAndProc = true;
    sandbox.extraPaths = [
      "/sys/devices"
      "/sys/block"  # for zram usage
    ];
    fs.".config/htop/htoprc".symlink.target = ./htoprc;
  };
}
