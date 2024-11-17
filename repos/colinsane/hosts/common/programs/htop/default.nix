{ ... }:
{
  sane.programs.htop = {
    sandbox.keepPidsAndProc = true;
    sandbox.extraPaths = [
      "/sys/devices"
    ];
    fs.".config/htop/htoprc".symlink.target = ./htoprc;
  };
}
