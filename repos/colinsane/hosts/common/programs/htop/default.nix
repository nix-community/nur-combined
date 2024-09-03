{ ... }:
{
  sane.programs.htop = {
    sandbox.method = "bunpen";
    sandbox.isolatePids = false;
    sandbox.extraPaths = [
      "/proc"
      "/sys/devices"
    ];
    fs.".config/htop/htoprc".symlink.target = ./htoprc;
  };
}
